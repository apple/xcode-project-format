//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0 with Runtime Library Exception
// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// The name of a build configuration.
    ///
    /// Most commonly "Debug" or "Release".
    public struct ConfigurationName: XCSchema.TypedStringWrapper, Sendable {
        public var name: String

        public init(name: String) {
            self.name = name
        }

        public init(rawValue: String) {
            self.init(name: rawValue)
        }

        public var rawValue: String {
            name
        }
    }
}

