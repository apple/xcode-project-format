//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation

extension XCSchema {
    /// A version number, encoded as major, minor, and update components.
    ///
    /// Currently used to record metadata about the last Xcode upgrade or Swift migration check performed on a project or target. For example, `26.3.1`.
    public struct MarketingVersion: Hashable, Sendable {
        public var major: Int
        public var minor: Int
        public var update: Int

        public init(major: Int, minor: Int, update: Int) {
            self.major = major
            self.minor = minor
            self.update = update
        }
    }
}

extension XCSchema.MarketingVersion: XCJSON.StringCodable {
    public init(encodableStringRepresentation string: String) throws {
        let components = string.components(separatedBy: ".").completeMap { component in
            Int(component)
        }
        if let components, (2...3).contains(components.count) {
            major = components[0]
            minor = components[1]
            update = (components.count >= 3) ? Int(components[2]) : 0
        } else {
            throw NSError("Invalid version string \(string.smartQuoted).")
        }
    }

    public var encodableStringRepresentation: String {
        if (update == 0) {
            return "\(major).\(minor)"
        } else {
            return "\(major).\(minor).\(update)"
        }
    }
}
