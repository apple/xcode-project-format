//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCJSON {
    package enum ValueType: Hashable, Sendable {
        case null
        case boolean
        case integer
        case double
        case string
        case array
        case object

        var errorMessageName: String {
            switch self {
                case .null: "null"
                case .boolean: "boolean"
                case .integer: "integer"
                case .double: "double"
                case .string: "string"
                case .array: "array"
                case .object: "dictionary"
            }
        }
    }
}
