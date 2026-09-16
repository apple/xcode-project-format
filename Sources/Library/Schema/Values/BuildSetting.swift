//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// The value of a build setting.
    ///
    /// A build setting can be either a string, or an array of strings.
    public enum BuildSetting: Equatable, Sendable {
        case string(String)
        case array([String])
    }
}

extension XCSchema.BuildSetting: XCJSON.Codable {
    package func encode(with coder: XCJSON.Encoder) throws {
        switch self {
            case let .string(content):
                try content.encode(with: coder)
            case let .array(content):
                try content.encode(with: coder)
        }
    }

    package init(with coder: XCJSON.Decoder) throws {
        if coder.currentNodeType == .string {
            self = try .string(.init(with: coder))
        } else {
            self = try .array(.init(with: coder))
        }
    }
}
