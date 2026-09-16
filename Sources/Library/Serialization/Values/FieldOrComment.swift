//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation



extension XCJSON {
    package indirect enum FieldOrComment: Hashable, Sendable {
        case field(Field)
        case comment(Comment)

        package enum Kind: Equatable {
            case field
            case comment
        }

        package var isField: Bool {
            kind == .field
        }

        package var kind: Kind {
            switch self {
                case .field: .field
                case .comment: .comment
            }
        }

        package var field: Field? {
            switch self {
                case .field(let field): field
                case .comment: nil
            }
        }

        package static func field(_ key: String, _ value: Value) -> FieldOrComment {
            .field(Field(key, value))
        }

        package static func boolean(_ key: String, _ value: Bool) -> FieldOrComment {
            .field(Field(key, .boolean(value)))
        }
        package static func integer(_ key: String, _ value: Int) -> FieldOrComment {
            .field(Field(key, .integer(value)))
        }
        package static func double(_ key: String, _ value: Double) -> FieldOrComment {
            .field(Field(key, .double(value)))
        }
        package static func string(_ key: String, _ value: String) -> FieldOrComment {
            .field(Field(key, .string(value)))
        }
        package static func array(_ key: String, _ value: [ValueOrComment]) -> FieldOrComment {
            .field(Field(key, .array(value)))
        }
        package static func object(_ key: String, _ value: [FieldOrComment]) -> FieldOrComment {
            .field(Field(key, .object(value)))
        }
        package static func object(_ key: String, _ value: Object) -> FieldOrComment {
            .field(Field(key, .object(value)))
        }
    }
}
