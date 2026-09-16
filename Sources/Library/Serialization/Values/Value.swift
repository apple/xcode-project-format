//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

package import Foundation


extension XCJSON {
    package indirect enum Value: Hashable, Sendable {
        case null
        case boolean(Bool)
        case integer(Int)
        case double(Double)
        case string(String)
        case array([ValueOrComment])
        case object(Object)

        package var type: ValueType {
            switch self {
                case .null: .null
                case .boolean: .boolean
                case .integer: .integer
                case .double: .double
                case .string: .string
                case .array: .array
                case .object: .object
            }
        }

        package static func object(_ content: [FieldOrComment]) -> Value {
            .object(Object(content))
        }


        package init(data: Data) throws {
#if canImport(Darwin)
            // On Darwin, we can leverage obj-c dispatch to significantly speed up the `Any` -> `XCJSON.Value` transformation.
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [.json5Allowed, .fragmentsAllowed])
            let builder = Builder()
            let nsObject = jsonObject as! NSObject
            nsObject.xcjson_buildValue(into: builder)
            self = builder.result
#else
            let decoder = JSONDecoder()
            decoder.allowsJSON5 = true
            self = try decoder.decode(Value.self, from: data)
#endif
        }
    }
}

extension XCJSON.Value {
    package func textRepresentation(options: XCJSON.EncodingOptions, densities: [XCJSON.AbsolutePath: XCJSON.PrintingDensity] = [:]) -> String {
        String(bytes: dataRepresentation(options: options, densities: densities), encoding: .utf8).unwrapOrAssertUnreachable()
    }

    package func dataRepresentation(options: XCJSON.EncodingOptions, densities: [XCJSON.AbsolutePath: XCJSON.PrintingDensity] = [:]) -> Data {
        XCJSON.Printer.data(self, options: options, explicitPrintingDensities: densities)
    }
}

#if canImport(Darwin)

extension XCJSON {
    fileprivate class Builder: NSObject {
        var result: XCJSON.Value = .null
    }
}

extension NSObject {
    // This entry point will be ~55% faster than `XCJSON.Value(anyJSON:)` when you're coming from a bunch of objc types.
    @objc fileprivate func xcjson_buildValue(into builder: XCJSON.Builder) {
        preconditionFailure()
    }
}

extension NSNull {
    @objc fileprivate override func xcjson_buildValue(into builder: XCJSON.Builder) {
        builder.result = .null
    }
}

extension NSNumber {
    @objc fileprivate override func xcjson_buildValue(into builder: XCJSON.Builder) {
        if CFGetTypeID(self) == CFBooleanGetTypeID() {
            builder.result = .boolean(boolValue)
        } else if CFNumberIsFloatType(unsafeBitCast(self, to: CFNumber.self)) {
            builder.result = .double(doubleValue)
        } else {
            builder.result = .integer(intValue)
        }
    }
}

extension NSString {
    @objc fileprivate override func xcjson_buildValue(into builder: XCJSON.Builder) {
        builder.result = .string(self as String)
    }
}

extension NSArray {
    @objc fileprivate override func xcjson_buildValue(into builder: XCJSON.Builder) {
        let cfSelf = self as CFArray
        withExtendedLifetime(cfSelf) {
            withUnsafeTemporaryAllocation(of: UnsafeRawPointer?.self, capacity: count) { elements in
                CFArrayGetValues(cfSelf, CFRange(location: 0, length: count), elements.baseAddress)
                elements.withMemoryRebound(to: NSObject.self) { elements in
                    var content: [XCJSON.ValueOrComment] = Array(initialCapacity: count)
                    for element in elements {
                        element.xcjson_buildValue(into: builder)
                        content.append(.value(builder.result))
                    }
                    builder.result = .array(content)
                }
            }
        }
    }
}

extension NSDictionary {
    @objc fileprivate override func xcjson_buildValue(into builder: XCJSON.Builder) {
        let cfSelf = self as CFDictionary
        withExtendedLifetime(cfSelf) {
            withUnsafeTemporaryAllocation(of: UnsafeRawPointer?.self, capacity: count) { keys in
                withUnsafeTemporaryAllocation(of: UnsafeRawPointer?.self, capacity: count) { values in
                    CFDictionaryGetKeysAndValues(cfSelf, keys.baseAddress, values.baseAddress)
                    keys.withMemoryRebound(to: NSString.self) { keys in
                        values.withMemoryRebound(to: NSObject.self) { values in
                            var content: [XCJSON.FieldOrComment] = Array(initialCapacity: count)
                            for i in 0..<count {
                                values[i].xcjson_buildValue(into: builder)
                                content.append(.field(keys[i] as String, builder.result))
                            }
                            builder.result = .object(content)
                        }
                    }
                }
            }
        }
    }
}

#else

extension XCJSON.Value: Decodable {
    package init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let content = try? container.decode(String.self) {
            self = .string(content)
        } else if let content = try? container.decode(Bool.self) {
            self = .boolean(content)
        } else if let content = try? container.decode(Int.self) {
            self = .integer(content)
        } else if let content = try? container.decode([Self].self) {
            self = .array(content.map(XCJSON.ValueOrComment.value))
        } else if let content = try? container.decode([String: Self].self) {
            self = .object(content.map(XCJSON.FieldOrComment.field))
        } else if let content = try? container.decode(Double.self) {
            self = .double(content)
        } else if container.decodeNil() {
            self = .null
        } else {
            throw NSError("Unrecongized JSON object")
        }
    }
}

#endif

