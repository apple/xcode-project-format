//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// Identifies a platform that a build file can be explicitly limited to.
    public struct PlatformFilter: XCSchema.TypedStringWrapper, Sendable {
        public var platformID: String

        public init(platformID: String) {
            self.platformID = platformID
        }

        public init(rawValue: String) {
            self.init(platformID: rawValue)
        }

        public var rawValue: String {
            platformID
        }
    }
}

