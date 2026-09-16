//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation


extension XCSchema {
    /// Specifies a folder to add to the groups and files tree of a project.
    ///
    /// `Folder` differs from ``Group`` in that a folder will dynamically load its content from the file system at project load time, and keep it synchronized. Files from the folder will map to the folder's targets' build phases using default rules. The folder's `membershipExceptions` lists ``FolderExceptionSet`` instances that steer these default mappings.
    public struct Folder: Equatable, Sendable {
        public var path: XCSchema.FilePath
        public var targets: Set<LocalTargetReference>
        public var membershipExceptions: [FolderExceptionSet]
        public var explicitFileTypes: [FolderMemberID : FileTypeID]
        public var explicitOpaqueFolders: Set<FolderMemberID>
        public var commonProperties: CommonReferenceProperties
        public var objectID: ObjectID?

        public init(objectID: ObjectID?, path: XCSchema.FilePath, targets: Set<XCSchema.LocalTargetReference>, membershipExceptions: [FolderExceptionSet], explicitFileTypes: [FolderMemberID : FileTypeID], explicitOpaqueFolders: Set<FolderMemberID>, includeInIndex: Bool?) {
            self.objectID = objectID
            self.path = path
            self.targets = targets
            self.membershipExceptions = membershipExceptions
            self.explicitFileTypes = explicitFileTypes
            self.explicitOpaqueFolders = explicitOpaqueFolders
            self.commonProperties = CommonReferenceProperties(includeInIndex: includeInIndex)
        }
    }
}

extension XCSchema.Reference {
    package static func folder(path: XCSchema.FilePath, targets: Set<XCSchema.LocalTargetReference> = [], membershipExceptions: [XCSchema.FolderExceptionSet] = [], explicitFileTypes: [XCSchema.FolderMemberID :XCSchema.FileTypeID] = [:], explicitOpaqueFolders: Set<XCSchema.FolderMemberID> = [], includeInIndex: Bool? = nil) -> Self {
        .folder(
            XCSchema.Folder(
                objectID: nil,
                path: path,
                targets: targets,
                membershipExceptions: membershipExceptions,
                explicitFileTypes: explicitFileTypes,
                explicitOpaqueFolders: explicitOpaqueFolders,
                includeInIndex: includeInIndex,
            )
        )
    }
}

extension XCSchema.Folder: XCJSON.InlineKeyedCodable {
    package func encode(with container: XCJSON.Encoder.KeyedContainer) throws {
        try container.encode(objectID, for: "id", defaultValue: nil)
        try container.encode(inline: path)
        try container.encode(explicitFileTypes, for: "file-types", defaultValue: [:])
        try container.encode(explicitOpaqueFolders, for: "opaque-folders", defaultValue: [])
        try container.encode(targets, for: "target-membership", defaultValue: [])
        try container.encode(membershipExceptions, for: "membership-exceptions", defaultValue: [])
        try container.encode(inline: commonProperties)
    }

    package init(with container: XCJSON.Decoder.KeyedContainer) throws {
        path = try container.decodeInline()
        objectID = try container.decode("id", defaultValue: nil)
        explicitFileTypes = try container.decode("file-types", defaultValue: [:])
        explicitOpaqueFolders = try container.decode("opaque-folders", defaultValue: [])
        targets = try container.decode("target-membership", defaultValue: [])
        membershipExceptions = try container.decode("membership-exceptions", defaultValue: [])
        commonProperties = try container.decodeInline()
    }

    var printingDensity: XCJSON.PrintingDensity? {
        membershipExceptions.isEmpty ? .compact : nil
    }
}

