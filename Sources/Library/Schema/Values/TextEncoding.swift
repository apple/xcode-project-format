//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

public import Foundation


extension XCSchema {
    /// A subset of the text encodings usable as the explicit encoding of a file reference.
    ///
    /// Specifically, a subset of `String.Encoding` values usable with a `project.xcproj` file as the explicit text encoding of ``FileReference`` objects.
    public struct TextEncoding: Hashable, Sendable {
        public var rawValue: String.Encoding

        public init(rawValue: String.Encoding) {
            self.rawValue = rawValue
        }
    }
}

extension XCSchema.TextEncoding: XCJSON.Codable {
    package func encode(with coder: XCJSON.Encoder) throws {
        try rawValue.encode(with: coder)
    }

    package init(with coder: XCJSON.Decoder) throws {
        rawValue = try String.Encoding(with: coder)
    }
}


