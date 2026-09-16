//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation


extension XCJSON {
    package indirect enum ValueOrComment: Hashable, Sendable {
        case value(Value)
        case comment(Comment)

        package var isValue: Bool {
            kind == .value
        }

        package var value: Value? {
            switch self {
                case .value(let value): value
                case .comment: nil
            }
        }

        package enum Kind: Equatable {
            case value
            case comment
        }

        package var kind: Kind {
            switch self {
                case .value: .value
                case .comment: .comment
            }
        }

        package static func bool(_ value: Bool) -> ValueOrComment {
            .value(.boolean(value))
        }
        package static func integer(_ value: Int) -> ValueOrComment {
            .value(.integer(value))
        }
        package static func double(_ value: Double) -> ValueOrComment {
            .value(.double(value))
        }
        package static func string(_ value: String) -> ValueOrComment {
            .value(.string(value))
        }
        package static func array(_ value: [ValueOrComment]) -> ValueOrComment {
            .value(.array(value))
        }

        package static func object(_ value: [FieldOrComment]) -> ValueOrComment {
            .value(.object(value))
        }

        package static func object(_ value: Object) -> ValueOrComment {
            .value(.object(value))
        }

        package static func comment(style: CommentStyle, content: String) throws -> ValueOrComment {
            try .comment(Comment(style: style, content: content))
        }
    }
}
