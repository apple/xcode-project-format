//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation


extension XCSchema {
    /// Specifies the exceptional inclusions or exclusions of an exception set, along with attributes for the included files.
    ///
    /// The attributes cover platform filters, build file attributes like header role, and asset tags.
    public struct CommonExceptionSetProperties: Equatable, Sendable {
        public var sense: ExceptionSetSense // Only for archive legibility.
        public var membershipExceptions: Set<FolderMemberID>
        public var platformFiltersByFolderMemberID: [FolderMemberID : Set<XCSchema.PlatformFilter>]
        public var attributesByFolderMemberID: [FolderMemberID : XCSchema.BuildFileAttributes]
        public var assetTagsByFolderMemberID: [FolderMemberID : Set<XCSchema.AssetTag>]

        public init(sense: ExceptionSetSense, membershipExceptions: Set<FolderMemberID>, platformFiltersByFolderMemberID: [FolderMemberID : Set<XCSchema.PlatformFilter>], attributesByFolderMemberID: [FolderMemberID : XCSchema.BuildFileAttributes], assetTagsByFolderMemberID: [FolderMemberID : Set<XCSchema.AssetTag>]) {
            self.sense = sense
            self.membershipExceptions = membershipExceptions
            self.platformFiltersByFolderMemberID = platformFiltersByFolderMemberID
            self.attributesByFolderMemberID = attributesByFolderMemberID
            self.assetTagsByFolderMemberID = assetTagsByFolderMemberID
        }
    }
}

extension XCSchema.CommonExceptionSetProperties: XCJSON.InlineKeyedCodable {
    package func encode(with container: XCJSON.Encoder.KeyedContainer) throws {
        if membershipExceptions != [] {
            try container.encode(membershipExceptions, forUnverifiedKey: sense.key, unconditionally: .affirmative)
        }
        try container.encode(platformFiltersByFolderMemberID.withCompactValueEncoding(), for: "platforms", defaultValue: [:])
        try container.encode(attributesByFolderMemberID.withCompactValueEncoding(), for: "attributes", defaultValue: [:])
        try container.encode(assetTagsByFolderMemberID.withCompactValueEncoding(), for: "asset-tags", defaultValue: [:])
    }

    package init(with container: XCJSON.Decoder.KeyedContainer) throws {
        let allSenses = XCSchema.ExceptionSetSense.allCases
        let senses = allSenses.filter { candidate in
            container.contains(candidate.key)
        }
        if let senseKey = senses.only {
            sense = senseKey
            membershipExceptions = try container.decode(senseKey.key, defaultValue: [])
        } else if !senses.hasContent {
            sense = .inclusions
            membershipExceptions = []
        } else {
            throw NSError(description: "Multiple exception set senses", recoverySuggestion: "Expected one of \(allSenses.map(\.key.smartQuoted).joined(by: ", ", finalSeparator: " or "))")
        }
        platformFiltersByFolderMemberID = try container.decode("platforms", defaultValue: [:])
        attributesByFolderMemberID = try container.decode("attributes", defaultValue: [:])
        assetTagsByFolderMemberID = try container.decode("asset-tags", defaultValue: [:])
    }
}

