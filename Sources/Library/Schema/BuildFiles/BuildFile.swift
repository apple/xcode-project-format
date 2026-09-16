//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// Represents a file's membership in a build phase.
    ///
    /// Specifically, maps a ``FileReference`` into a ``BuildPhase``. In addition to signifying target membership, carries optional values describing how the build might be customized, like whether a header should be public or private. A `ProjectBuildFile` differs from a ``TargetBuildFile`` in that its only assumed context is the project.
    public struct ProjectBuildFile: Equatable, Sendable {
        public var objectID: ObjectID?
        public var buildPhase: ProjectBuildPhaseReference
        public var properties: BuildFileProperties

        public init(objectID: ObjectID?, buildPhase: ProjectBuildPhaseReference, properties: BuildFileProperties) {
            self.objectID = objectID
            self.buildPhase = buildPhase
            self.properties = properties
        }
    }

    /// Represents a file's membership in a build phase.
    ///
    /// Specifically, maps a ``FileReference`` into a ``BuildPhase``. In addition to signifying target membership, carries optional values describing how the build might be customized, like whether a header should be public or private. A `TargetBuildFile` differs from a ``ProjectBuildFile`` in that its target is already known by context.
    public struct TargetBuildFile: Equatable, Sendable {
        public var buildPhase: TargetBuildPhaseReference
        public var properties: BuildFileProperties
        public var objectID: ObjectID?

        public init(objectID: ObjectID?, buildPhase: TargetBuildPhaseReference, properties: BuildFileProperties) {
            self.objectID = objectID
            self.buildPhase = buildPhase
            self.properties = properties
        }
    }

    /// Customizes the way a build file behaves in a build phase, for example by limiting to a specific set of platforms, marking headers as public/private, adding custom compiler flags, etc.
    public struct BuildFileProperties: Equatable, Sendable {
        public var platformFilters: Set<PlatformFilter>
        public var attributes: BuildFileAttributes
        public var additionalBuildFlags: String?
        public var assetTags: Set<AssetTag>

        public init(platformFilters: Set<PlatformFilter>, additionalBuildFlags: String?, assetTags: Set<AssetTag>, attributes: BuildFileAttributes) {
            self.platformFilters = platformFilters
            self.additionalBuildFlags = additionalBuildFlags
            self.assetTags = assetTags
            self.attributes = attributes
        }

        static let defaultInstance = Self(
            platformFilters: [],
            additionalBuildFlags: nil,
            assetTags: [],
            attributes: .defaultInstance
        )

        internal var everythingIsDefault: Bool {
            self == Self.defaultInstance
        }
    }
}

extension XCSchema.ProjectBuildFile: XCJSON.Codable {
    package func encode(with coder: XCJSON.Encoder) throws {
        if (objectID == nil) && properties.everythingIsDefault, buildPhase.groupTreeReferenceRepresentation.encodesToString {
            try buildPhase.encode(with: coder)
        } else {
            let container = coder.openKeyedContainer(density: .compact)
            try container.encode(objectID, for: "id", defaultValue: nil)
            try container.encode(buildPhase, for: "build-phase", unconditionally: .affirmative)
            try container.encode(inline: properties)
        }
    }

    package init(with coder: XCJSON.Decoder) throws {
        if coder.currentNodeType == .string {
            buildPhase = try XCSchema.ProjectBuildPhaseReference(with: coder)
            properties = .defaultInstance
            objectID = nil
        } else {
            let container = try coder.openKeyedContainer()
            objectID = try container.decode("id", defaultValue: nil)
            buildPhase = try container.decode("build-phase")
            properties = try container.decodeInline()
        }
    }
}

extension XCSchema.TargetBuildFile: XCJSON.Codable {
    package func encode(with coder: XCJSON.Encoder) throws {
        let container = coder.openKeyedContainer(density: .compact)
        try container.encode(objectID, for: "id", defaultValue: nil)
        try container.encode(buildPhase, for: "build-phase", unconditionally: .affirmative)
        try container.encode(inline: properties)
    }

    package init(with coder: XCJSON.Decoder) throws {
        let container = try coder.openKeyedContainer()
        objectID = try container.decode("id", defaultValue: nil)
        buildPhase = try container.decode("build-phase")
        properties = try container.decodeInline()
    }
}

extension XCSchema.BuildFileProperties: XCJSON.InlineKeyedCodable {
    package func encode(with container: XCJSON.Encoder.KeyedContainer) throws {
        try container.encode(platformFilters, for: "platforms", defaultValue: [], density: .compact)
        try container.encode(inline: attributes)
        try container.encode(additionalBuildFlags, for: "arguments", defaultValue: nil)
        try container.encode(assetTags, for: "asset-tags", defaultValue: [], density: .compact)
    }

    package init(with container: XCJSON.Decoder.KeyedContainer) throws {
        platformFilters = try container.decode("platforms", defaultValue: [])
        attributes = try container.decodeInline()
        additionalBuildFlags = try container.decode("arguments", defaultValue: nil)
        assetTags = try container.decode("asset-tags", defaultValue: [])
    }
}


