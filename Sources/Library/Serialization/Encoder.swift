//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

package import Foundation

extension XCJSON.Encoder {
    package typealias ValueOrComment = XCJSON.ValueOrComment
    package typealias FieldOrComment = XCJSON.FieldOrComment
    package typealias Value = XCJSON.Value
    package typealias Comment = XCJSON.Comment
    package typealias CommentStyle = XCJSON.CommentStyle
}

extension XCJSON {
    package enum PrintingDensity: Equatable {
        case compact
        case sprawling
    }

    package struct EncodingOptions: CopyWith {
        package static let defaultOptions = EncodingOptions()

        package var addTrailingNewline = true
    }

    package class Encoder {
        fileprivate var currentContainer: AbstractContainer? = nil
        private var explicitPrintingDensity: [AbsolutePath: PrintingDensity] = [:]

        private func openContainer<Container: AbstractContainer>(_ container: Container, density: PrintingDensity?) -> Container {
            currentContainer = container
            if let density {
                explicitPrintingDensity[container.path] = density
            }
            return container
        }

        package func openPrimitiveContainer() -> PrimitiveContainer {
            openContainer(PrimitiveContainer(encoder: self), density: nil)
        }

        package func openOrdinalContainer(density: PrintingDensity? = nil) -> OrdinalContainer {
            openContainer(OrdinalContainer(encoder: self), density: density)
        }

        package func openKeyedContainer(density: PrintingDensity? = nil) -> KeyedContainer {
            openContainer(KeyedContainer(encoder: self), density: density)
        }

        fileprivate func encode(_ value: some XCJSON.Encodable) throws -> Value {
            let originalContainer = currentContainer
            try value.encode(with: self)
            if originalContainer === currentContainer {
                // they didn't write anything
                return .object([])
            } else {
                let openedContainer = currentContainer.unwrapOrAssertUnreachable()
                let openedExactlyOneContainer = (openedContainer.parentContainer === originalContainer)
                precondition(openedExactlyOneContainer)
                currentContainer = originalContainer
                return openedContainer.finishEncoding()
            }
        }

        package static func json(for value: some Encodable) throws -> Value {
            try Encoder().encode(value)
        }

        package static func text(for value: some Encodable, options: XCJSON.EncodingOptions) throws -> String {
            let data = try data(for: value, options: options)
            return String(data: data, encoding: .utf8).unwrapOrAssertUnreachable()
        }

        package static func value(for value: some Encodable, options: XCJSON.EncodingOptions) throws -> XCJSON.Value {
            let encoder = Encoder()
            return try encoder.encode(value)
        }

        package static func data(for value: some Encodable, options: XCJSON.EncodingOptions) throws -> Data {
            let encoder = Encoder()
            let value = try encoder.encode(value)
            return Printer.data(value, options: options, explicitPrintingDensities: encoder.explicitPrintingDensity)
        }

        package func encodePrimitive(_ value: Bool) {
            openPrimitiveContainer().encode(value)
        }

        package func encodePrimitive(_ value: Int) {
            openPrimitiveContainer().encode(value)
        }

        package func encodePrimitive(_ value: Double) {
            openPrimitiveContainer().encode(value)
        }

        package func encodePrimitive(_ value: String) {
            openPrimitiveContainer().encode(value)
        }

        package func encodePrimitive<StringValue: StringEncodable>(_ value: StringValue) throws {
            try value.encode(with: self)
        }
    }
}

extension XCJSON.Encoder {
    package class AbstractContainer {
        fileprivate var encoder: XCJSON.Encoder
        fileprivate var parentContainer: AbstractContainer?
        fileprivate var path: XCJSON.AbsolutePath
        fileprivate var componentBeingEncoded: XCJSON.PathComponent?
        fileprivate init(encoder: XCJSON.Encoder) {
            self.encoder = encoder
            self.parentContainer = encoder.currentContainer
            if let parentContainer {
                path = XCJSON.AbsolutePath(parent: parentContainer.path, component: parentContainer.componentBeingEncoded.unwrapOrAssertUnreachable())
            } else {
                path = .root
            }
        }

        fileprivate func comment(_ comment: Comment) {
            preconditionFailure("Abstract")
        }

        package final func comment(style: CommentStyle, _ content: String) throws {
            comment(try Comment(style: style, content: content))
        }

        fileprivate func finishEncoding() -> Value {
            preconditionFailure("Abstract")
        }
    }
}

extension XCJSON.Encoder {
    package class PrimitiveContainer: AbstractContainer {
        fileprivate var encodedValue: Value? = nil

        fileprivate func encodeValue(_ value: Value) {
            precondition(encodedValue == nil)
            encodedValue = value
        }

        package func encodeNil() {
            encodeValue(.null)
        }

        package func encode(_ value: Bool) {
            encodeValue(.boolean(value))
        }

        package func encode(_ value: Int) {
            encodeValue(.integer(value))
        }

        package func encode(_ value: Double) {
            encodeValue(.double(value))
        }

        package func encode(_ value: String) {
            encodeValue(.string(value))
        }

        fileprivate override func finishEncoding() -> XCJSON.Encoder.Value {
            if let encodedValue {
                return encodedValue
            } else {
                preconditionFailure()
            }
        }
    }
}

extension XCJSON.Encoder {
    package class OrdinalContainer: AbstractContainer {
        fileprivate var valueOrComments: [ValueOrComment] = []
        fileprivate override func comment(_ comment: Comment) {
            valueOrComments.append(.comment(comment))
        }

        package func encode<Value: XCJSON.Encodable>(_ value: Value, density: XCJSON.PrintingDensity? = nil) throws {
            let index = valueOrComments.count
            componentBeingEncoded = .index(index)
            try valueOrComments.append(.value(encoder.encode(value)))
            componentBeingEncoded = nil
            if let density {
                setDensity(density, for: index)
            }
        }

        fileprivate override func finishEncoding() -> Value {
            return .array(valueOrComments)
        }

        private func setDensity(_ density: XCJSON.PrintingDensity, for index: Int) {
            encoder.explicitPrintingDensity[path.appending(.index(index))] = density
        }
    }
}

extension XCJSON.Encoder {
    package class KeyedContainer: AbstractContainer {
        fileprivate var fieldOrComments: [FieldOrComment] = []
        #if DEBUG
        fileprivate var encodedKeys: Set<String> = []
        #endif

        fileprivate override func finishEncoding() -> Value {
            return .object(fieldOrComments)
        }

        fileprivate override func comment(_ comment: Comment) {
            fieldOrComments.append(.comment(comment))
        }

        package enum Affirmative {
            case affirmative
        }

        package func encode<Value: XCJSON.Encodable>(_ value: Value, forUnverifiedKey key: String, unconditionally: Affirmative, density: XCJSON.PrintingDensity? = nil) throws {
            #if DEBUG
                let firstValueForKey = encodedKeys.insert(key).inserted
                precondition(firstValueForKey, "Encoded the key \(key.smartQuoted) multiple times.")
            #endif
            componentBeingEncoded = .key(key)
            if let density {
                setDensity(density, for: key)
            }
            try fieldOrComments.append(.field(key, encoder.encode(value)))
            componentBeingEncoded = nil
        }

        package func encode<Value: XCJSON.Encodable>(_ value: Value, for key: String, unconditionally: Affirmative, density: XCJSON.PrintingDensity? = nil) throws {
            #if DEBUG
                precondition(key.isSpearCase)
            #endif
            try encode(value, forUnverifiedKey: key, unconditionally: .affirmative, density: density)
        }

        package func encode<Value: XCJSON.Encodable & Equatable>(_ value: Value, for key: String, defaultValue: Value, density: XCJSON.PrintingDensity? = nil) throws {
            if value != defaultValue {
                try encode(value, for: key, unconditionally: .affirmative, density: density)
            }
        }

        package func encode<Value: XCJSON.InlineKeyedEncodable>(inline value: Value?) throws {
            try value?.encode(with: self)
        }

        private func setDensity(_ density: XCJSON.PrintingDensity, for key: String) {
            encoder.explicitPrintingDensity[path.appending(.key(key))] = density
        }
    }
}

