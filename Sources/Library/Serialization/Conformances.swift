//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation

extension Bool: XCJSON.Codable {
    package func encode(with coder: XCJSON.Encoder) throws {
        coder.openPrimitiveContainer().encode(self)
    }

    package init(with coder: XCJSON.Decoder) throws {
        self = try coder.openPrimitiveContainer().decode()
    }
}

extension Int: XCJSON.Codable {
    package func encode(with coder: XCJSON.Encoder) throws {
        coder.openPrimitiveContainer().encode(self)
    }

    package init(with coder: XCJSON.Decoder) throws {
        self = try coder.openPrimitiveContainer().decode()
    }
}

extension Double: XCJSON.Codable {
    package func encode(with coder: XCJSON.Encoder) throws {
        coder.openPrimitiveContainer().encode(self)
    }

    package init(with coder: XCJSON.Decoder) throws {
        self = try coder.openPrimitiveContainer().decode()
    }
}

extension Float: XCJSON.Codable {
    package func encode(with coder: XCJSON.Encoder) throws {
        coder.openPrimitiveContainer().encode(Double(self))
    }

    package init(with coder: XCJSON.Decoder) throws {
        self = try Float(coder.openPrimitiveContainer().decode() as Double)
    }
}

extension String: XCJSON.StringCodable {
    package var encodableStringRepresentation: String {
        self
    }

    package init(encodableStringRepresentation: String) {
        self = encodableStringRepresentation
    }
}

extension Optional: XCJSON.Encodable where Wrapped: XCJSON.Encodable {
    package func encode(with coder: XCJSON.Encoder) throws {
        if let wrapped = self {
            try wrapped.encode(with: coder)
        } else {
            coder.openPrimitiveContainer().encodeNil()
        }
    }
}

extension Optional: XCJSON.Decodable where Wrapped: XCJSON.Decodable {
    package init(with coder: XCJSON.Decoder) throws {
        if coder.currentNodeType == .null {
            self = .none
        } else {
            self = try .some(Wrapped(with: coder))
        }
    }
}

extension Array: XCJSON.Encodable where Element: XCJSON.Encodable {
    package func encode(with coder: XCJSON.Encoder) throws {
        let container = coder.openOrdinalContainer()
        for element in self {
            try container.encode(element)
        }
    }
}

extension Array: XCJSON.Decodable where Element: XCJSON.Decodable {
    package init(with coder: XCJSON.Decoder) throws {
        let container = try coder.openOrdinalContainer()
        self.init()
        self.reserveCapacity(container.count)
        for index in container.indices {
            try self.append(container.decode(at: index))
        }
    }
}

extension XCJSON {
    package protocol CodableOrderable {
        static func lessThanForCoding(lhs: Self, rhs: Self) -> Bool
    }
}

extension XCJSON.CodableOrderable where Self: Comparable {
    package static func lessThanForCoding(lhs: Self, rhs: Self) -> Bool {
        lhs < rhs
    }
}

extension XCJSON.CodableOrderable where Self: XCJSON.StringEncodable {
    package static func lessThanForCoding(lhs: Self, rhs: Self) -> Bool {
        lhs.encodableStringRepresentation < rhs.encodableStringRepresentation
    }
}

extension String: XCJSON.CodableOrderable {
    package static func lessThanForCoding(lhs: Self, rhs: Self) -> Bool {
        lhs < rhs
    }
}

extension Set: XCJSON.Encodable where Element: XCJSON.Encodable & XCJSON.CodableOrderable {
    package func encode(with coder: XCJSON.Encoder) throws {
        let container = coder.openOrdinalContainer()
        for element in self.sorted(by: Element.lessThanForCoding) {
            try container.encode(element)
        }
    }
}

extension Set: XCJSON.Decodable where Element: XCJSON.Decodable {
    package init(with coder: XCJSON.Decoder) throws {
        let container = try coder.openOrdinalContainer()
        self.init()
        self.reserveCapacity(container.count)
        for index in container.indices {
            try self.insert(container.decode(at: index))
        }
        if self.count != container.count {
            throw NSError("Decoding a set produced duplicate elements")
        }
    }
}

extension Dictionary: XCJSON.Encodable where Key: XCJSON.StringCodable, Value: XCJSON.Encodable {
    package func encode(with coder: XCJSON.Encoder) throws {
        let container = coder.openKeyedContainer()
        var intermediate: [(key: String, value: Value)] = self.map { entry in
            (entry.key.encodableStringRepresentation, entry.value)
        }
        intermediate.sort { lhs, rhs in
            lhs.key < rhs.key
        }
        for (key, value) in intermediate {
            try container.encode(value, forUnverifiedKey: key.encodableStringRepresentation, unconditionally: .affirmative)
        }
    }
}

extension Dictionary: XCJSON.Decodable where Key: XCJSON.StringCodable, Value: XCJSON.Decodable {
    package init(with coder: XCJSON.Decoder) throws {
        let container = try coder.openKeyedContainer()
        self.init()
        self.reserveCapacity(container.count)
        for keyString in container.keys {
            let key = try Key(encodableStringRepresentation: keyString)
            self[key] = try container.decode(keyString)
        }
    }
}

extension XCJSON {
    package protocol StringEncodable: XCJSON.Encodable {
        var encodableStringRepresentation: String { get }
    }
}

extension XCJSON {
    package protocol StringDecodable: XCJSON.Decodable {
        init(encodableStringRepresentation: String) throws
    }
}

extension XCJSON {
    package typealias StringCodable = StringEncodable & StringDecodable
}

extension XCJSON.StringEncodable {
    package func encode(with coder: XCJSON.Encoder) throws {
        coder.openPrimitiveContainer().encode(encodableStringRepresentation)
    }
}

extension XCJSON.StringDecodable {
    package init(with coder: XCJSON.Decoder) throws {
        self = try Self(encodableStringRepresentation: coder.decodePrimitive())
    }
}

extension XCJSON.StringEncodable where Self: RawRepresentable, Self.RawValue == String {
    package var encodableStringRepresentation: String {
        rawValue
    }
}

extension XCJSON.StringDecodable where Self: RawRepresentable, Self.RawValue == String {
    package init(encodableStringRepresentation string: String) throws {
        if let decoded = Self(rawValue: string) {
            self = decoded
        } else {
            throw NSError("Unexpected value \(string.smartQuoted)")
        }
    }
}
