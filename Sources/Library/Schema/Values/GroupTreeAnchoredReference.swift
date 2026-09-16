//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// A path to a file system object, starting from some element in the project's groups and files tree.
    ///
    /// References a groups and files tree element via a `GroupTreeReference`, then uses a relative path through the file system encoded via `NamePath`.
    ///
    /// Instances of `GroupTreeAnchoredReference` are used to encode the xcconfig for a build configuration that may be discovered content from a `Folder` reference.
    public struct GroupTreeAnchoredReference: Equatable, CustomStringConvertible, Sendable {
        public var anchor: GroupTreeReference
        public var relativePath: NamePath?

        public init(anchor: GroupTreeReference, relativePath: NamePath?) {
            self.anchor = anchor
            self.relativePath = relativePath
        }

        public var description: String {
            if let relativePath {
                anchor.description + "/" + relativePath.description
            } else {
                anchor.description
            }
        }
    }
}

extension XCSchema.GroupTreeAnchoredReference: XCJSON.Codable {
    fileprivate static let idSignalingPrefix = "id:"
    package func encode(with coder: XCJSON.Encoder) throws {
        if let relativePath {
            let container = coder.openKeyedContainer()
            try container.encode(anchor, for: "anchor", unconditionally: .affirmative)
            try container.encode(relativePath, for: "relative-path", unconditionally: .affirmative)
        } else {
            try anchor.encode(with: coder)
        }
    }

    package init(with coder: XCJSON.Decoder) throws {
        if coder.currentNodeType == .object {
            let container = try coder.openKeyedContainer()
            anchor = try container.decode("anchor")
            relativePath = try container.decode("relative-path") as NamePath
        } else {
            anchor = try GroupTreeReference(with: coder)
        }
    }
}


