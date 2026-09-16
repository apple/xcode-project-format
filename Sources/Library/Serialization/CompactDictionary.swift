//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCJSON {
    package struct CompactDictionary<Key: Hashable, Value: Equatable>: Equatable {
        var storage: Dictionary<Key, Value> = [:]
    }
}

extension XCJSON.CompactDictionary: ExpressibleByDictionaryLiteral {
    package init(dictionaryLiteral elements: (Key, Value)...) {
        for (key, value) in elements {
            storage[key] = value
        }
    }
}

extension XCJSON.CompactDictionary: XCJSON.Encodable where Key: XCJSON.StringCodable, Value: XCJSON.Encodable {
    package func encode(with coder: XCJSON.Encoder) throws {
        let container = coder.openKeyedContainer()
        var intermediate: [(key: String, value: Value)] = storage.map { entry in
            (entry.key.encodableStringRepresentation, entry.value)
        }
        intermediate.sort(on: \.key)
        for (key, value) in intermediate {
            try container.encode(value, forUnverifiedKey: key.encodableStringRepresentation, unconditionally: .affirmative, density: .compact)
        }
    }
}

extension Dictionary {
    /// It's explicitly permitted to decode this as the original dictionary type.
    func withCompactValueEncoding() -> XCJSON.CompactDictionary<Key, Value> where Value: Equatable {
        XCJSON.CompactDictionary(storage: self)
    }
}
