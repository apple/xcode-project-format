//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// An unambiguous unique ID for an object in the project graph.
    ///
    /// The `ObjectID` instances are any string, but by convention UUID-like. The `project.xcproj` prefers to minimize the usage of `ObjectID` for forming references, since they're difficult to read compared to name and path based references. But when names aren't unique enough to form precise references, ObjectIDs are used.
    ///
    /// Some elements in Xcode can be referenced by external files. For example, Xcode targets can be referenced by other projects. These references are always ID based, and so some elements in a `project.xcproj` should always have IDs, but those IDs should only be used as a last resort within the file for encoding cross tree references.
    public struct ObjectID: XCSchema.TypedStringWrapper, Sendable {
        public var rawValue: String

        public init(_ value: String) {
            self.rawValue = value
        }

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

