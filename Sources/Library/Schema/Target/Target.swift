//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation

extension XCSchema {
    /// Represents a buildable entity in the project, like an application, framework, or command line tool.
    ///
    /// Targets hold build settings, build rules, and dependencies, but not their files. Instead, the `Reference` objects from the project's groups and files tree inject themselves into their targets.
    public enum Target: Equatable, CopyWith, Sendable {
        case native(CommonTargetProperties)
        case aggregate(CommonTargetProperties)
        case externalBuildSystem(ExternalBuildSystemTargetProperties)

        public enum Kind: String, XCJSON.StringCodable, Sendable {
            case native = "native"
            case aggregate = "aggregate"
            case externalBuildSystem = "external-build-system"
        }

        /// Identifies which kind of target this is.
        ///
        /// The default target type is `native`, and you can use `aggregate` targets to refer to a collection of targets, and `externalBuildSystem` to integrate a project using a build tool like `make` into an Xcode project.
        public var kind: Kind {
            switch self {
                case .native: .native
                case .aggregate: .aggregate
                case .externalBuildSystem: .externalBuildSystem
            }
        }

        public var commonProperties: CommonTargetProperties {
            switch self {
                case let .native(properties): properties
                case let .aggregate(properties): properties
                case let .externalBuildSystem(properties): properties.commonProperties
            }
        }

        public var name: String {
            commonProperties.name
        }
    }

    /// The instance properties shared by every kind of target.
    ///
    /// Specifically, shared by all cases of ``Target``.
    public struct CommonTargetProperties: Equatable, CopyWith, Sendable {
        public var objectID: ObjectID
        public var name: String
        public var dependencies: [TargetDependency]
        public var buildPhases: [BuildPhase]
        public var buildRules: [BuildRule]
        public var specializedConfigurations: [Configuration]
        public var buildSettings: [String: BuildSetting]
        public var product: GroupTreeReference?
        public var productTypeID: ProductTypeID?
        public var testHostTarget: LocalTargetReference?
        public var legacyProvisioningStyle: LegacyProvisioningStyle?
        public var legacyTeamID: String?
        public var lastSwiftUpdateCheck: MarketingVersion?
        public var lastSwiftMigration: MarketingVersion?
        public var packageProductTargetMembers: [SwiftPackageProductTargetMember]
        public var configurationListDebugID: ObjectID?

        public init(name: String, objectID: ObjectID, configurationListDebugID: ObjectID?, dependencies: [TargetDependency], buildPhases: [BuildPhase], buildRules: [BuildRule], specializedConfigurations: [Configuration], buildSettings: [String: BuildSetting], product: GroupTreeReference?, productTypeID: ProductTypeID?, testHostTarget: LocalTargetReference?, legacyProvisioningStyle: LegacyProvisioningStyle?, legacyTeamID: String?, lastSwiftUpdateCheck: MarketingVersion?, lastSwiftMigration: MarketingVersion?, packageProductTargetMembers: [SwiftPackageProductTargetMember]) {
            self.name = name
            self.objectID = objectID
            self.dependencies = dependencies
            self.buildPhases = buildPhases
            self.buildRules = buildRules
            self.specializedConfigurations = specializedConfigurations
            self.buildSettings = buildSettings
            self.product = product
            self.productTypeID = productTypeID
            self.testHostTarget = testHostTarget
            self.legacyProvisioningStyle = legacyProvisioningStyle
            self.legacyTeamID = legacyTeamID
            self.lastSwiftUpdateCheck = lastSwiftUpdateCheck
            self.lastSwiftMigration = lastSwiftMigration
            self.packageProductTargetMembers = packageProductTargetMembers
            self.configurationListDebugID = configurationListDebugID
        }
    }

    /// The instance properties used by the external-build-system target case.
    ///
    /// Specifically, used by ``Target/externalBuildSystem(_:)``.
    public struct ExternalBuildSystemTargetProperties: Equatable, CopyWith, Sendable {
        public var commonProperties: CommonTargetProperties
        public var buildToolPath: String
        public var buildToolArguments: String
        public var buildToolWorkingDirectory: String?
        public var passBuildSettingsInEnvironment: Bool

        public init(commonProperties: CommonTargetProperties, buildToolPath: String, buildToolArguments: String, buildToolWorkingDirectory: String?, passBuildSettingsInEnvironment: Bool) {
            self.commonProperties = commonProperties
            self.buildToolPath = buildToolPath
            self.buildToolArguments = buildToolArguments
            self.buildToolWorkingDirectory = buildToolWorkingDirectory
            self.passBuildSettingsInEnvironment = passBuildSettingsInEnvironment
        }
    }
}

extension XCSchema.Target: XCJSON.Codable {
    package func encode(with coder: XCJSON.Encoder) throws {
        let container = coder.openKeyedContainer()
        switch self {
            case let .native(content): try content.encode(with: container, kind: .native)
            case let .aggregate(content): try content.encode(with: container, kind: .aggregate)
            case let .externalBuildSystem(content): try content.encode(with: container)
        }
    }

    package init(with coder: XCJSON.Decoder) throws {
        let container = try coder.openKeyedContainer()
        let kind = try container.decode("kind", defaultValue: Kind.native)
        switch kind {
            case .native: self = try .native(.init(with: container))
            case .aggregate: self = try .aggregate(.init(with: container))
            case .externalBuildSystem: self = try .externalBuildSystem(.init(with: container))
        }
    }
}

extension XCSchema.CommonTargetProperties: XCJSON.InlineKeyedDecodable {
    package func encode(with container: XCJSON.Encoder.KeyedContainer, kind: XCSchema.Target.Kind) throws {
        for configuration in specializedConfigurations {
            if !configuration.isSpecialized {
                throw NSError("Redundant configuration specialization for \(configuration.name.rawValue.smartQuoted) in \(name.smartQuoted)")
            }
        }
        try container.encode(name, for: "name", unconditionally: .affirmative)
        try container.encode(objectID, for: "id", unconditionally: .affirmative)
        try container.encode(configurationListDebugID, for: "configuration-list-debug-id", defaultValue: nil)
        try container.encode(kind, for: "kind", defaultValue: .native)
        try container.encode(product, for: "product", defaultValue: nil)
        try encodeProductType(container: container)
        try container.encode(lastSwiftUpdateCheck, for: "last-swift-update", defaultValue: nil)
        try container.encode(lastSwiftMigration, for: "last-swift-migration", defaultValue: nil)
        try container.encode(legacyProvisioningStyle, for: "legacy-provisioning-style", defaultValue: nil)
        try container.encode(legacyTeamID, for: "legacy-team-id", defaultValue: nil)
        try container.encode(testHostTarget, for: "test-host-target", defaultValue: nil)
        try container.encode(specializedConfigurations.withCompactValueEncoding(), for: "specialized-configurations", defaultValue: [])
        try container.encode(dependencies, for: "dependencies", defaultValue: [])
        try container.encode(buildPhases, for: "build-phases", defaultValue: [])
        try container.encode(buildRules, for: "build-rules", defaultValue: [])
        try container.encode(packageProductTargetMembers.sorted(on: \.encodingOrder), for: "package-product-members", defaultValue: [])
        try container.encode(buildSettings, for: "build-settings", defaultValue: [:])
    }

    package init(with container: XCJSON.Decoder.KeyedContainer) throws {
        name = try container.decode("name")
        objectID = try container.decode("id")
        product = try container.decode("product", defaultValue: nil)
        productTypeID = try Self.decodeProductType(container: container)
        testHostTarget = try container.decode("test-host-target", defaultValue: nil)
        lastSwiftUpdateCheck = try container.decode("last-swift-update", defaultValue: nil)
        lastSwiftMigration = try container.decode("last-swift-migration", defaultValue: nil)
        legacyProvisioningStyle = try container.decode("legacy-provisioning-style", defaultValue: nil)
        legacyTeamID = try container.decode("legacy-team-id", defaultValue: nil)
        dependencies = try container.decode("dependencies", defaultValue: [])
        buildRules = try container.decode("build-rules", defaultValue: [])
        buildPhases = try container.decode("build-phases", defaultValue: [])
        specializedConfigurations = try container.decode("specialized-configurations", defaultValue: [])
        buildSettings = try container.decode("build-settings", defaultValue: [:])
        packageProductTargetMembers = try container.decode("package-product-members", defaultValue: [])
        configurationListDebugID = try container.decode("configuration-list-debug-id", defaultValue: nil)
    }

    private func encodeProductType(container: XCJSON.Encoder.KeyedContainer) throws {
        if let abbreviatedID = productTypeID?.abbreviatedRepresentation {
            try container.encode(abbreviatedID, for: "product-type", defaultValue: nil)
        } else {
            try container.encode(productTypeID, for: "full-product-type", defaultValue: nil)
        }
    }

    private static func decodeProductType(container: XCJSON.Decoder.KeyedContainer) throws -> XCSchema.ProductTypeID? {
        if container.contains("product-type") {
            return try XCSchema.ProductTypeID(abbreviatedRepresentation: container.decode("product-type"))
        } else {
            return try container.decodeIfPresent("full-product-type")
        }
    }
}

extension XCSchema.ExternalBuildSystemTargetProperties: XCJSON.InlineKeyedCodable {
    package func encode(with container: XCJSON.Encoder.KeyedContainer) throws {
        try commonProperties.encode(with: container, kind: .externalBuildSystem)
        try container.encode(buildToolPath, for: "build-tool-path", unconditionally: .affirmative)
        try container.encode(buildToolArguments, for: "build-tool-arguments", defaultValue: "")
        try container.encode(buildToolWorkingDirectory, for: "build-tool-working-directory", defaultValue: nil)
        try container.encode(passBuildSettingsInEnvironment, for: "pass-build-settings-in-environment", defaultValue: true)
    }

    package init(with container: XCJSON.Decoder.KeyedContainer) throws {
        commonProperties = try XCSchema.CommonTargetProperties(with: container)
        buildToolPath = try container.decode("build-tool-path")
        buildToolArguments = try container.decode("build-tool-arguments", defaultValue: "")
        buildToolWorkingDirectory = try container.decode("build-tool-working-directory", defaultValue: nil)
        passBuildSettingsInEnvironment = try container.decode("pass-build-settings-in-environment", defaultValue: true)
    }
}
