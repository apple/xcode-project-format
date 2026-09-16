//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    protocol TypedStringWrapper: XCJSON.StringCodable, XCJSON.CodableOrderable, Hashable, CustomStringConvertible {
        var rawValue: String { get }
        init(rawValue: String)
    }
}

extension XCSchema.TypedStringWrapper {
    public init(encodableStringRepresentation value: String) throws {
        self.init(rawValue: value)
    }

    public var encodableStringRepresentation: String {
        rawValue
    }

    public var description: String {
        rawValue
    }
}
