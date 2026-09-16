//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// Used to specify one of the languages a project is localized into.
    public struct Language: XCSchema.TypedStringWrapper, Sendable {
        public var languageID: String

        public init(languageID: String) {
            self.languageID = languageID
        }

        public init(rawValue: String) {
            self.init(languageID: rawValue)
        }

        public var rawValue: String {
            languageID
        }
    }
}


