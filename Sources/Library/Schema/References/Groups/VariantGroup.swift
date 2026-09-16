//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// Represents a localized resource in a project, where the children are the language specific variants of the resource.
    public struct VariantGroup: Equatable, Sendable {
        static let defaultFilePath = try! XCSchema.FilePath(base: .group, path: "")
        public var name: String
        public var path: FilePath
        public var commonProperties: CommonReferenceProperties
        public var buildFiles: [ProjectBuildFile]
        public var children: [FileReference]
        public var objectID: ObjectID?

        public init(objectID: ObjectID?, name: String, path: FilePath, includeInIndex: Bool?, buildFiles: [ProjectBuildFile], children: [FileReference]) {
            self.objectID = objectID
            self.name = name
            self.path = path
            self.commonProperties = CommonReferenceProperties(includeInIndex: includeInIndex)
            self.children = children
            self.buildFiles = buildFiles
        }
    }
}


extension XCSchema.Reference {
    package static func variantGroup(name: String, path: XCSchema.FilePath, includeInIndex: Bool? = nil, buildFiles: [XCSchema.ProjectBuildFile], children: [XCSchema.FileReference]) -> Self {
        .variantGroup(
            XCSchema.VariantGroup(
                objectID: nil,
                name: name,
                path: path,
                includeInIndex: includeInIndex,
                buildFiles: buildFiles,
                children: children,
            )
        )
    }
}


extension XCSchema.VariantGroup: XCJSON.InlineKeyedCodable {
    package func encode(with container: XCJSON.Encoder.KeyedContainer) throws {
        try container.encode(objectID, for: "id", defaultValue: nil)
        try container.encode(inline: path)
        try container.encode(name, for: "name", defaultValue: path.path.lastPathComponent)
        try container.encode(inline: commonProperties)
        try container.encode(buildFiles, for: "target-membership", defaultValue: [])
        try container.encode(children, for: "children", defaultValue: [])
    }

    package init(with container: XCJSON.Decoder.KeyedContainer) throws {
        objectID = try container.decode("id", defaultValue: nil)
        path = try container.decodeInline()
        name = try container.decode("name", defaultValue: path.path.lastPathComponent)
        commonProperties = try container.decodeInline()
        buildFiles = try container.decode("target-membership", defaultValue: [])
        children = try container.decode("children", defaultValue: [])
    }

    var printingDensity: XCJSON.PrintingDensity? {
        (children.isEmpty && (buildFiles.count <= 1)) ? .compact : nil
    }
}
