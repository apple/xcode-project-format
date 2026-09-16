//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// A reference to a local Swift package via project relative path.
    public struct LocalSwiftPackage: Equatable, Sendable {
        /// A project relative path.
        public var path: String

        public init(path: String) {
            self.path = path
        }
    }
}


extension XCSchema.LocalSwiftPackage: XCJSON.InlineKeyedCodable {
    package func encode(with container: XCJSON.Encoder.KeyedContainer) throws {
        try container.encode(path, for: "path", unconditionally: .affirmative)
    }

    package init(with container: XCJSON.Decoder.KeyedContainer) throws {
        path = try container.decode("path")
    }
}
