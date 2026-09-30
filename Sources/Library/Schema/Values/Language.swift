//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0 with Runtime Library Exception
// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
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


