//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// Represents a versioned source file, like a Core Data model.
    public struct VersionGroup: Equatable, Sendable {
        public var name: String
        public var path: FilePath
        public var currentVersion: GroupTreeReference?
        public var versionedFileType: FileTypeID?
        public var commonProperties: CommonReferenceProperties
        public var children: [FileReference]
        public var buildFiles: [ProjectBuildFile]
        public var objectID: ObjectID?

        public init(objectID: ObjectID?, name: String, path: FilePath, currentVersion: GroupTreeReference?, versionedFileType: FileTypeID?, includeInIndex: Bool?, buildFiles: [ProjectBuildFile], children: [FileReference]) {
            self.objectID = objectID
            self.name = name
            self.currentVersion = currentVersion
            self.versionedFileType = versionedFileType
            self.path = path
            self.commonProperties = CommonReferenceProperties(includeInIndex: includeInIndex)
            self.buildFiles = buildFiles
            self.children = children
        }
    }
}

extension XCSchema.Reference {
    package static func versionGroup(name: String, path: XCSchema.FilePath, currentVersion: GroupTreeReference? = nil, versionedFileType: XCSchema.FileTypeID? = nil, includeInIndex: Bool? = nil, buildFiles: [XCSchema.ProjectBuildFile] = [], children: [XCSchema.FileReference] = []) -> Self {
        .versionGroup(
            XCSchema.VersionGroup(
                objectID: nil,
                name: name,
                path: path,
                currentVersion: currentVersion,
                versionedFileType: versionedFileType,
                includeInIndex: includeInIndex,
                buildFiles: buildFiles,
                children: children,
            )
        )
    }
}


extension XCSchema.VersionGroup: XCJSON.InlineKeyedCodable {
    package func encode(with container: XCJSON.Encoder.KeyedContainer) throws {
        try container.encode(objectID, for: "id", defaultValue: nil)
        try container.encode(inline: path)
        try container.encode(name, for: "name", defaultValue: path.path.lastPathComponent)
        try container.encode(currentVersion, for: "current-version", defaultValue: nil)
        try container.encode(versionedFileType, for: "type", defaultValue: nil)
        try container.encode(inline: commonProperties)
        try container.encode(buildFiles, for: "target-membership", defaultValue: [])
        try container.encode(children, for: "children", defaultValue: [])
    }

    package init(with container: XCJSON.Decoder.KeyedContainer) throws {
        objectID = try container.decode("id", defaultValue: nil)
        path = try container.decodeInline()
        name = try container.decode("name", defaultValue: path.path.lastPathComponent)
        currentVersion = try container.decode("current-version", defaultValue: nil)
        versionedFileType = try container.decode("type", defaultValue: nil)
        commonProperties = try container.decodeInline()
        buildFiles = try container.decode("target-membership", defaultValue: [])
        children = try container.decode("children", defaultValue: [])
    }

    var printingDensity: XCJSON.PrintingDensity? {
        (children.isEmpty && (buildFiles.count <= 1)) ? .compact : nil
    }
}
