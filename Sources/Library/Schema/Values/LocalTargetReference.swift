//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// Specifies enough information to look up a target when the project is known.
    ///
    /// Targets within a project must have unique names, so no ID based fallback is needed like other referencing schemes.
    public struct LocalTargetReference: XCSchema.TypedStringWrapper, Sendable {
        public var targetName: String

        public init(targetName: String) {
            self.targetName = targetName
        }

        public init(rawValue: String) {
            self.init(targetName: rawValue)
        }

        public var rawValue: String {
            targetName
        }
    }
}

