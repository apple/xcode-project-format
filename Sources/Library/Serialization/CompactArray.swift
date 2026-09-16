//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCJSON {
    package struct CompactArray<Element: Equatable>: Equatable {
        var storage: [Element] = []
    }
}

extension XCJSON.CompactArray: ExpressibleByArrayLiteral {
    package init(arrayLiteral elements: Element...) {
        storage.reserveCapacity(elements.count)
        for element in elements {
            storage.append(element)
        }
    }
}

extension XCJSON.CompactArray: XCJSON.Encodable where Element: XCJSON.Encodable {
    package func encode(with coder: XCJSON.Encoder) throws {
        let container = coder.openOrdinalContainer()
        for element in storage {
            try container.encode(element, density: .compact)
        }
    }
}

extension Array {
    /// It's explicitly permitted to decode this as the original array type.
    func withCompactValueEncoding() -> XCJSON.CompactArray<Element> where Element: Equatable {
        XCJSON.CompactArray(storage: self)
    }
}


extension Set {
    /// It's explicitly permitted to decode this as the original array type.
    func withCompactValueEncoding() -> XCJSON.CompactArray<Element> where Element: Equatable & XCJSON.CodableOrderable {
        XCJSON.CompactArray(storage: sorted(by: Element.lessThanForCoding))
    }
}
