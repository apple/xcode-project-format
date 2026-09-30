//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0 with Runtime Library Exception
// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
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
