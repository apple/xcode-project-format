//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// Represents a group in the project's file tree.
    ///
    /// Groups typically represent a directory, and have children representing all of the directory content, but this is only by convention. A group's children can be in entirely unrelated portions of the file system.
    ///
    /// For an exact file system representation into a project, prefer ``Folder``; it minimizes replication between the project file and the file system, and greatly reduces the chance of merge conflicts. When a specialized reflection of the file system into a project is needed, a group is the best choice.
    public struct Group: Equatable, Sendable {
        public var name: String // Not encoded when equal to last path component.
        public var path: FilePath
        public var commonProperties: CommonReferenceProperties
        public var children: [Reference]
        public var objectID: ObjectID?

        public init(objectID: ObjectID?, name: String, path: FilePath, includeInIndex: Bool?, children: [Reference]) {
            self.objectID = objectID
            self.path = path
            self.commonProperties = CommonReferenceProperties(includeInIndex: includeInIndex)
            self.name = name
            self.children = children
        }
    }
}

extension XCSchema.Reference {
    package static func group(name: String, path: XCSchema.FilePath, includeInIndex: Bool?, children: [XCSchema.Reference]) -> Self {
        .group(
            XCSchema.Group(
                objectID: nil,
                name: name,
                path: path,
                includeInIndex: includeInIndex,
                children: children,
            )
        )
    }

    package static func group(path: XCSchema.FilePath, includeInIndex: Bool? = nil, children: [XCSchema.Reference]) -> Self {
        .group(
            XCSchema.Group(
                objectID: nil,
                name: path.path.lastPathComponent,
                path: path,
                includeInIndex: includeInIndex,
                children: children,
            )
        )
    }
}


extension XCSchema.Group: XCJSON.InlineKeyedCodable {
    package func encode(with container: XCJSON.Encoder.KeyedContainer) throws {
        try container.encode(objectID, for: "id", defaultValue: nil)
        try container.encode(inline: path)
        try container.encode(name, for: "name", defaultValue: path.path.lastPathComponent)
        try container.encode(inline: commonProperties)
        try container.encode(children, for: "children", defaultValue: [])
    }

    package init(with container: XCJSON.Decoder.KeyedContainer) throws {
        objectID = try container.decode("id", defaultValue: nil)
        path = try container.decodeInline()
        name = try container.decode("name", defaultValue: path.path.lastPathComponent)
        commonProperties = try container.decodeInline()
        children = try container.decode("children", defaultValue: [])
    }

    var printingDensity: XCJSON.PrintingDensity? {
        children.isEmpty ? .compact : nil
    }
}
