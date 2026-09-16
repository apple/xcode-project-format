//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

package import Foundation


extension XCJSON.Decoder {
    package typealias ValueOrComment = XCJSON.ValueOrComment
    package typealias FieldOrComment = XCJSON.FieldOrComment
    package typealias Value = XCJSON.Value
    package typealias Comment = XCJSON.Comment
    package typealias CommentStyle = XCJSON.CommentStyle
}

extension XCJSON {
    package class Decoder {
        internal var toolNameForErrorMessages = "Xcode"
        fileprivate var currentValue: Value
        fileprivate var currentPath = XCJSON.AbsolutePath.root
        fileprivate init(rootValue: Value) {
            self.currentValue = rootValue
        }

        fileprivate func decode<Decoded: Decodable>(_ value: Value, pathComponent: XCJSON.PathComponent) throws -> Decoded {
            let oldPath = currentPath; defer {
                currentPath = oldPath
            }
            let oldCurrentValue = value; defer {
                currentValue = oldCurrentValue
            }
            let newPath = AbsolutePath(parent: oldPath, component: pathComponent)
            currentValue = value
            currentPath = newPath
            do {
                return try Decoded(with: self)
            } catch {
                var error = error as NSError
                if error.userInfo(for: NSError.xcodeProjectFormatJSONCodingPathUserInfoKey) == nil {
                    error = error.errorWith(userInfoKey: NSError.xcodeProjectFormatJSONCodingPathUserInfoKey, value: newPath.description)
                }
                throw error
            }
        }

        package static func decode<Decoded: Decodable>(value: Value) throws -> Decoded {
            return try Decoded(with: Decoder(rootValue: value))
        }

        package static func decode<Decoded: Decodable>(data: Data) throws -> Decoded {
            return try decode(value: Value(data: data))
        }

        package func openPrimitiveContainer() throws -> PrimitiveContainer {
            try PrimitiveContainer(decoder: self)
        }

        package func openOrdinalContainer() throws -> OrdinalContainer {
            try OrdinalContainer(decoder: self)
        }

        package func openKeyedContainer() throws -> KeyedContainer {
            try KeyedContainer(decoder: self)
        }

        package var currentNodeType: XCJSON.ValueType {
            currentValue.type
        }

        package func decodePrimitive() throws -> Bool {
            try openPrimitiveContainer().decode()
        }

        package func decodePrimitive() throws -> Int {
            try openPrimitiveContainer().decode()
        }

        package func decodePrimitive() throws -> Double {
            try openPrimitiveContainer().decode()
        }

        package func decodePrimitive() throws -> String {
            try openPrimitiveContainer().decode()
        }

        package func decodePrimitive<StringValue: StringDecodable>() throws -> StringValue {
            try StringValue(with: self)
        }

        package func delegateDecoding<Value: XCJSON.Decodable>() throws -> Value {
            try Value(with: self)
        }

        fileprivate func errorForExpectedType(_ expectedType: XCJSON.ValueType) -> NSError {
            NSError("Expected an instance of \(expectedType.errorMessageName) but an instance \(currentValue.type) was specified")
        }
    }
}

extension XCJSON.Decoder {
    package class AbstractContainer {
        fileprivate let decoder: XCJSON.Decoder
        fileprivate let path: XCJSON.AbsolutePath
        fileprivate init(decoder: XCJSON.Decoder) throws {
            self.decoder = decoder
            self.path = decoder.currentPath
        }
    }
}

extension XCJSON.Decoder {
    package class PrimitiveContainer: AbstractContainer {
        let value: Value

        fileprivate override init(decoder: XCJSON.Decoder) throws {
            self.value = decoder.currentValue
            try super.init(decoder: decoder)
        }

        package var isNull: Bool {
            return value == .null
        }

        package func decode() throws -> Bool {
            if case let .boolean(value) = value {
                return value
            } else {
                throw decoder.errorForExpectedType(.boolean)
            }
        }

        package func decode() throws -> Int {
            if case let .integer(value) = value {
                return value
            } else {
                throw decoder.errorForExpectedType(.integer)
            }
        }

        package func decode() throws -> Double {
            if case let .double(value) = value {
                return value
            } else {
                throw decoder.errorForExpectedType(.double)
            }
        }

        package func decode() throws -> String {
            if case let .string(value) = value {
                return value
            } else {
                throw decoder.errorForExpectedType(.string)
            }
        }
    }
}

extension XCJSON.Decoder {
    package class OrdinalContainer: AbstractContainer {
        private var elements: [Value]

        fileprivate override init(decoder: XCJSON.Decoder) throws {
            if case let .array(entries) = decoder.currentValue {
                self.elements = entries.compactMap(\.value)
                try super.init(decoder: decoder)
            } else {
                throw decoder.errorForExpectedType(.array)
            }
        }

        package var indices: Range<Int> {
            elements.indices
        }

        package var count: Int {
            elements.count
        }

        package func decode<Decoded: XCJSON.Decodable>(at index: Int) throws -> Decoded {
            try decoder.decode(elements[index], pathComponent: .index(index))
        }
    }
}

extension XCJSON.Decoder {
    package class KeyedContainer: AbstractContainer {
        private var fields: [String: Value] = [:]

        fileprivate override init(decoder: XCJSON.Decoder) throws {
            if case let .object(object) = decoder.currentValue {
                let fieldOrComments = object.fieldsOrComments
                self.fields.reserveCapacity(fieldOrComments.count)
                for fieldOrComment in fieldOrComments {
                    if let field = fieldOrComment.field {
                        self.fields[field.key] = field.value
                    }
                }
                try super.init(decoder: decoder)
            } else {
                throw decoder.errorForExpectedType(.object)
            }
        }

        package func decode<Decoded: XCJSON.Decodable>(_ key: String) throws -> Decoded {
            if let value = fields[key] {
                try decoder.decode(value, pathComponent: .key(key))
            } else {
                throw NSError("Missing required value for key \(key.smartQuoted) at \(path.description.smartQuoted)")
            }
        }

        // Rough. Assume a type like `struct T { var: nickName: String? }` with a `nickName = container.decode("nick-name", defaultValue: "little-one")` the compiler will choose the generic func with `Decoded = String` not String?, which means if we explicitly encoded nil, we'll fail to decode it propertly. Maybe re-think not passing the type to the decode methods.
        package func decodeOptionalWithNonNilDefault<Decoded: XCJSON.Decodable>(_ key: String, defaultValue: Decoded) throws -> Decoded? {
            if let value = fields[key] {
                return try decoder.decode(value, pathComponent: .key(key))
            } else {
                return defaultValue
            }
        }

        package func decode<Decoded: XCJSON.Decodable>(_ key: String, defaultValue: Decoded) throws -> Decoded {
            if let value = fields[key] {
                return try decoder.decode(value, pathComponent: .key(key))
            } else {
                return defaultValue
            }
        }

        package func decodeIfPresent<Decoded: XCJSON.Decodable>(_ key: String) throws -> Decoded? {
            if let value = fields[key] {
                return try decoder.decode(value, pathComponent: .key(key))
            } else {
                return nil
            }
        }

        package func decodeInline<Value: XCJSON.InlineKeyedDecodable>() throws -> Value {
            try Value(with: self)
        }

        package var count: Int {
            fields.count
        }

        package var keys: some Collection<String> {
            fields.keys
        }

        package func contains(_ key: String) -> Bool {
            return fields[key] != nil
        }
    }
}
