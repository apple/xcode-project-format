//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// A single element in the groups and files tree.
    public enum Reference: Equatable, Sendable {
        package enum Kind: String, XCJSON.StringCodable, Equatable {
            case fileReference = "file-reference"
            case group = "group"
            case folder = "folder"
            case variantGroup = "variant-group"
            case versionGroup = "version-group"

            public var encodableStringRepresentation: String {
                rawValue
            }
        }

        case fileReference(FileReference)
        case group(Group)
        case folder(Folder)
        case variantGroup(VariantGroup)
        case versionGroup(VersionGroup)

        var kind: Kind {
            switch self {
                case .fileReference: .fileReference
                case .group: .group
                case .folder: .folder
                case .variantGroup: .variantGroup
                case .versionGroup: .versionGroup
            }
        }
    }

    /// The values common to every kind of file-tree reference.
    ///
    /// Specifically, common to all cases of the ``Reference`` enumeration.
    public struct CommonReferenceProperties: Equatable, Sendable {
        public var includeInIndex: Bool?
    }
}


extension XCSchema.Reference: XCJSON.Codable {
    package func encode(with coder: XCJSON.Encoder) throws {
        let container = coder.openKeyedContainer(density: printingDensity)
        try container.encode(kind, for: "kind", defaultValue: .fileReference)
        switch self {
            case .fileReference(let content): try content.encode(with: container)
            case .group(let content): try content.encode(with: container)
            case .folder(let content): try content.encode(with: container)
            case .variantGroup(let content): try content.encode(with: container)
            case .versionGroup(let content): try content.encode(with: container)
        }
    }

    package init(with coder: XCJSON.Decoder) throws {
        let container = try coder.openKeyedContainer()
        let kind: Kind = try container.decode("kind", defaultValue: .fileReference)
        switch kind {
            case .fileReference:
                self = try .fileReference(XCSchema.FileReference(with: container))
            case .group:
                self = try .group(XCSchema.Group(with: container))
            case .folder:
                self = try .folder(XCSchema.Folder(with: container))
            case .variantGroup:
                self = try .variantGroup(XCSchema.VariantGroup(with: container))
            case .versionGroup:
                self = try .versionGroup(XCSchema.VersionGroup(with: container))
        }
    }

    var printingDensity: XCJSON.PrintingDensity? {
        switch self {
            case .fileReference(let content): content.printingDensity
            case .group(let content): content.printingDensity
            case .folder(let content): content.printingDensity
            case .variantGroup(let content): content.printingDensity
            case .versionGroup(let content): content.printingDensity
        }
    }
}
extension XCSchema.CommonReferenceProperties: XCJSON.InlineKeyedCodable {
    package func encode(with container: XCJSON.Encoder.KeyedContainer) throws {
        try container.encode(includeInIndex, for: "index", defaultValue: nil)
    }

    package init(with container: XCJSON.Decoder.KeyedContainer) throws {
        includeInIndex = try container.decode("index", defaultValue: nil)
    }
}
