//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// Forms sets of assets that are faulted in at runtime with the Apple platform feature "On Demand Resources".
    public struct AssetTag: XCSchema.TypedStringWrapper, Sendable {
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


