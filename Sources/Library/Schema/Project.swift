//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

public import Foundation


extension XCSchema {
    /// The root object of the file format.
    ///
    /// Each `project.xcproj` decodes to one instance of this structure. See the conceptual documentation for an overview of how all of the pieces fit together.
    /// The project is primarily composed of the groups and files tree (aka `topLevelReferences`), a list of targets, a list of build configurations, and build settings.
    public struct Project: Equatable, Sendable {
        public var topLevelReferences: [Reference]
        public var packages: [SwiftPackage]
        public var configurations: [Configuration]
        public var defaultConfigurationName: ConfigurationName
        public var buildSettings: [String: BuildSetting]
        public var targets: [Target]
        public var localizationInfo: ProjectLocalizationInfo
        public var requiredCapabilities: Set<Capability>
        public var buildIndependentTargetsInParallel: Bool
        public var lastUpgradeCheck: MarketingVersion?
        public var lastSwiftUpdateCheck: MarketingVersion?
        public var lastSwiftMigration: MarketingVersion?
        public var organizationName: String?
        public var classPrefix: String?
        public var productsGroup: GroupTreeReference?
        public var objectID: ObjectID?
        public var rootGroupDebugID: ObjectID?
        public var configurationListDebugID: ObjectID?
        public var importedProducts: [RemoteProduct]

        public init(objectID: ObjectID?, rootGroupDebugID: ObjectID?, configurationListDebugID: ObjectID?, topLevelReferences: [Reference], packages: [SwiftPackage], configurations: [Configuration], buildSettings: [String : BuildSetting], defaultConfigurationName: ConfigurationName, targets: [Target], localizationInfo: ProjectLocalizationInfo, requiredCapabilities: Set<Capability>, buildIndependentTargetsInParallel: Bool, lastUpgradeCheck: MarketingVersion?, lastSwiftUpdateCheck: MarketingVersion?, lastSwiftMigration: MarketingVersion?, organizationName: String?, classPrefix: String?, productsGroup: GroupTreeReference?, importedProducts: [RemoteProduct]) {
            self.objectID = objectID
            self.rootGroupDebugID = rootGroupDebugID
            self.configurationListDebugID = configurationListDebugID
            self.topLevelReferences = topLevelReferences
            self.packages = packages
            self.configurations = configurations
            self.buildSettings = buildSettings
            self.defaultConfigurationName = defaultConfigurationName
            self.targets = targets
            self.localizationInfo = localizationInfo
            self.requiredCapabilities = requiredCapabilities
            self.buildIndependentTargetsInParallel = buildIndependentTargetsInParallel
            self.lastUpgradeCheck = lastUpgradeCheck
            self.lastSwiftUpdateCheck = lastSwiftUpdateCheck
            self.lastSwiftMigration = lastSwiftMigration
            self.organizationName = organizationName
            self.classPrefix = classPrefix
            self.productsGroup = productsGroup
            self.importedProducts = importedProducts
        }
    }
}

extension XCSchema.Project: XCJSON.Codable {
    struct VerificationIssue {
        enum Kind: Hashable {
            case duplicateTargetNames

            var title: String {
                switch self {
                    case .duplicateTargetNames: "Duplicate Target Names"
                }
            }

            var order: Int {
                switch self {
                    case .duplicateTargetNames: 0
                }
            }
        }

        var kind: Kind
        var message: String
    }

    private func collectTargetNameVerificationIssues(issues: inout [VerificationIssue]) {
        let ambiguousTargetNames = targets.duplicateValues(for: \.name)
        if ambiguousTargetNames.hasContent {
            let isAre = ambiguousTargetNames.count == 1 ? "is" : "are"
            let targetNames = ambiguousTargetNames.sorted().map(\.smartQuoted).joined(by: ", ", finalSeparator: " and ")
            let message = "Target names must be unique, but \(targetNames) \(isAre) used multiple times"
            issues.append(VerificationIssue(kind: .duplicateTargetNames, message: message))
        }
    }

    private func referenceIntegrityIssues() -> [VerificationIssue] {
        var issues: [VerificationIssue] = []
        collectTargetNameVerificationIssues(issues: &issues)
        return issues
    }

    private func verifyReferenceIntegrity() throws {
        let issues = referenceIntegrityIssues()
        if let onlyIssue = issues.only {
            throw NSError(onlyIssue.message)
        } else if issues.hasContent {
            let orderedGroups = Dictionary(grouping: issues, by: \.kind).sorted(on: \.key.order)
            var lines: [String] = []
            for (group, issues) in orderedGroups {
                lines.append(group.title)
                lines.append("")
                for issue in issues {
                    lines.append("• " + issue.message)
                }
            }
            lines.append("")
            throw NSError(lines.joined(separator: "\n"))
        }
    }

    static let defaultProductsReference = GroupTreeReference.namePath(XCSchema.NamePath(components: [.child("Products")]))

    package func encode(with coder: XCJSON.Encoder) throws {
        try verifyReferenceIntegrity()
        let container = coder.openKeyedContainer()
        try container.encode(requiredCapabilities, for: "required-capabilities", defaultValue: [])

        try container.encode(objectID, for: "id", defaultValue: nil)
        try container.encode(rootGroupDebugID, for: "root-group-debug-id", defaultValue: nil)
        try container.encode(configurationListDebugID, for: "configuration-list-debug-id", defaultValue: nil)
        try container.encode(organizationName, for: "organization", defaultValue: nil)
        try container.encode(classPrefix, for: "class-prefix", defaultValue: nil)
        try container.encode(buildIndependentTargetsInParallel, for: "build-independent-targets-in-parallel", defaultValue: true)
        try container.encode(defaultConfigurationName, for: "default-configuration", unconditionally: .affirmative)
        try container.encode(configurations.withCompactValueEncoding(), for: "configurations", defaultValue: [])
        try container.encode(localizationInfo, for: "localizations", unconditionally: .affirmative)
        try container.encode(importedProducts, for: "imported-products", defaultValue: [])
        try container.encode(packages, for: "packages", defaultValue: [])
        try container.encode(topLevelReferences, for: "files", unconditionally: .affirmative)
        try container.encode(targets, for: "targets", defaultValue: [])
        try container.encode(buildSettings, for: "build-settings", defaultValue: [:])
        // At the end on purpose because these are not the first thing users should see when opening a project file, even though it goes against the general rule to put non-collection attributes first.
        try container.encode(productsGroup, for: "products-group", defaultValue: Self.defaultProductsReference)
        try container.encode(lastUpgradeCheck, for: "last-upgrade", defaultValue: nil)
        try container.encode(lastSwiftUpdateCheck, for: "last-swift-update", defaultValue: nil)
        try container.encode(lastSwiftMigration, for: "last-swift-migration", defaultValue: nil)
    }

    package init(with coder: XCJSON.Decoder) throws {
        let container = try coder.openKeyedContainer()

        requiredCapabilities = try container.decode("required-capabilities", defaultValue: [])
        // Before we go any further, produce a good error message if needed.
        let unsatisfiedCapabilities = requiredCapabilities.all(where: \.isSatisfied, ==, false)
        if unsatisfiedCapabilities.hasContent {
            let list = unsatisfiedCapabilities.map(\.capabilityDescription).joined(by: ", ", finalSeparator: " and ")
            throw NSError("The project requires a newer version of \(coder.toolNameForErrorMessages) with support for " + list)
        }

        objectID = try container.decode("id", defaultValue: nil)
        rootGroupDebugID = try container.decode("root-group-debug-id", defaultValue: nil)
        configurationListDebugID = try container.decode("configuration-list-debug-id", defaultValue: nil)
        topLevelReferences = try container.decode("files")
        packages = try container.decode("packages", defaultValue: [])
        configurations = try container.decode("configurations", defaultValue: [])
        defaultConfigurationName = try container.decode("default-configuration")
        buildSettings = try container.decode("build-settings", defaultValue: [:])
        targets = try container.decode("targets", defaultValue: [])
        localizationInfo = try container.decode("localizations")
        buildIndependentTargetsInParallel = try container.decode("build-independent-targets-in-parallel", defaultValue: true)
        lastUpgradeCheck = try container.decodeIfPresent("last-upgrade")
        lastSwiftUpdateCheck = try container.decodeIfPresent("last-swift-update")
        lastSwiftMigration = try container.decodeIfPresent("last-swift-migration")
        organizationName = try container.decodeIfPresent("organization")
        classPrefix = try container.decodeIfPresent("class-prefix")
        productsGroup = try container.decodeOptionalWithNonNilDefault("products-group", defaultValue: Self.defaultProductsReference)
        importedProducts = try container.decode("imported-products", defaultValue: [])

        try verifyReferenceIntegrity()
    }
}

extension XCSchema.Project {
    public init(jsonRepresentation data: Data) throws {
        self = try XCJSON.Decoder.decode(data: data)
    }

    public func jsonRepresentation() throws -> Data {
        return try XCJSON.Encoder.data(for: self, options: .defaultOptions)
    }
}
