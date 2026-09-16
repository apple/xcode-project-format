//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// The name of a Swift package.
    public struct SwiftPackageName: XCJSON.StringCodable, Hashable, Sendable {
        public var packageName: String

        public init(packageName: String) {
            self.packageName = packageName
        }

        public init(encodableStringRepresentation: String) throws {
            packageName = encodableStringRepresentation
        }

        public var encodableStringRepresentation: String {
            packageName
        }
    }
}
