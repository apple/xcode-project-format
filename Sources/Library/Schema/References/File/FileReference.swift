//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation


extension XCSchema {
    /// Represents a file in the project.
    ///
    /// A file reference specifies a file in the groups and files tree, and has information about how to find the file on disk, as well as attributes related to the file's content, like an override type, explicit text encoding, line ending style, etc…
    /// Also used to map a file into a target, via the `buildFiles: [ProjectBuildFile]` setting which holds per-target-build-phase information.
    public struct FileReference: Equatable, Sendable {
        public var commonProperties: CommonReferenceProperties
        public var path: FilePath
        public var explicitFileType: FileTypeID?
        public var expectedSignature: String?
        public var textEncoding: TextEncoding?
        public var lineEnding: LineEnding?
        public var buildFiles: [ProjectBuildFile]
        public var objectID: ObjectID?

        public init(objectID: ObjectID?, path: FilePath, explicitFileType: FileTypeID?, expectedSignature: String?, textEncoding: TextEncoding?, lineEnding: LineEnding?, includeInIndex: Bool?, buildFiles: [ProjectBuildFile]) {
            self.objectID = objectID
            self.path = path
            self.explicitFileType = explicitFileType
            self.expectedSignature = expectedSignature
            self.textEncoding = textEncoding
            self.lineEnding = lineEnding
            self.commonProperties = CommonReferenceProperties(includeInIndex: includeInIndex)
            self.buildFiles = buildFiles
        }
    }

    /// Used to override a file's line ending handling by Xcode's editors.
    public enum LineEnding: String, XCJSON.StringCodable, Sendable {
        case lineFeed = "line-feed"
        case carriageReturn = "carriage-return"
        case carriageReturnLineFeed = "carriage-return-line-feed"
        case preserve = "preserve"
    }
}

extension XCSchema.FileReference: XCJSON.InlineKeyedCodable {
    package func encode(with container: XCJSON.Encoder.KeyedContainer) throws {
        try container.encode(inline: path)
        try container.encode(objectID, for: "id", defaultValue: nil)
        try container.encode(explicitFileType, for: "type", defaultValue: nil)
        try container.encode(expectedSignature, for: "signature", defaultValue: nil)
        try container.encode(textEncoding, for: "encoding", defaultValue: nil)
        try container.encode(lineEnding, for: "line-ending", defaultValue: nil)
        try container.encode(inline: commonProperties)
        try container.encode(buildFiles, for: "target-membership", defaultValue: [])
    }

    package init(with container: XCJSON.Decoder.KeyedContainer) throws {
        objectID = try container.decode("id", defaultValue: nil)
        path = try container.decodeInline()
        explicitFileType = try container.decode("type", defaultValue: nil)
        expectedSignature = try container.decode("signature", defaultValue: nil)
        textEncoding = try container.decode("encoding", defaultValue: nil)
        lineEnding = try container.decode("line-ending", defaultValue: nil)
        commonProperties = try container.decodeInline()
        buildFiles = try container.decode("target-membership", defaultValue: [])
    }

    var printingDensity: XCJSON.PrintingDensity? {
        buildFiles.count <= 1 ? .compact : nil
    }
}

