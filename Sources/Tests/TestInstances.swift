//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import XcodeProjectFormat
import Foundation
import Testing

protocol TestInstanceDefining {
    static var populatedTestValue: Self { get }
    static var emptyTestValue: Self { get }
    static var additionalTestValues: [Self] { get }
}

extension TestInstanceDefining {
    static var additionalTestValues: [Self] { [] }
}

extension XCSchema.AssetTag: TestInstanceDefining {
    static let populatedTestValue = Self(name: "release-asset")
    static let emptyTestValue = Self(name: "")
}

extension XCSchema.ObjectID: TestInstanceDefining {
    static let populatedTestValue = Self("0123456789ABCDEF")
    static let emptyTestValue = Self("FEDCBA9876543210")
}

extension XCSchema.Configuration: TestInstanceDefining {
    static let populatedTestValue = Self(name: .populatedTestValue, file: .populatedTestValue, objectID: .populatedTestValue)
    static let emptyTestValue = Self(name: .emptyTestValue, file: nil, objectID: nil)
}

extension XCSchema.BuildFileAttributes: TestInstanceDefining {
    static let populatedTestValue = Self(headerRole: .public, machInterfaceGeneration: .both, isWeak: true, codeSignOnCopy: true, codeGeneration: .skip, headerPreservation: .removeOnCopy, decompress: true, codeGenerationVisibility: .public)
    static let emptyTestValue = Self(headerRole: nil, machInterfaceGeneration: nil, isWeak: false, codeSignOnCopy: false, codeGeneration: .default, headerPreservation: .keep, decompress: false, codeGenerationVisibility: nil)
}

extension XCSchema.BuildFileProperties: TestInstanceDefining {
    static let populatedTestValue = Self(platformFilters: [.populatedTestValue], additionalBuildFlags: "--go-fast", assetTags: [.populatedTestValue], attributes: .populatedTestValue)
    static let emptyTestValue = Self(platformFilters: [], additionalBuildFlags: nil, assetTags: [], attributes: .emptyTestValue)
}

extension XCSchema.ProjectBuildFile: TestInstanceDefining {
    static let populatedTestValue = Self(objectID: .populatedTestValue, buildPhase: .populatedTestValue, properties: .populatedTestValue)
    static let emptyTestValue = Self(objectID: nil, buildPhase: .emptyTestValue, properties: .emptyTestValue)
}

extension XCSchema.TargetBuildFile: TestInstanceDefining {
    static let populatedTestValue = Self(objectID: .populatedTestValue, buildPhase: .populatedTestValue, properties: .populatedTestValue)
    static let emptyTestValue = Self(objectID: nil, buildPhase: .emptyTestValue, properties: .emptyTestValue)
}

extension XCSchema.BuildPhaseProperties: TestInstanceDefining {
    static let populatedTestValue = Self(objectID: .populatedTestValue, name: "Compile Sources")
    static let emptyTestValue = Self(objectID: nil, name: nil)
}

extension XCSchema.AppleScriptBuildPhaseProperties: TestInstanceDefining {
    static let populatedTestValue = Self(objectID: .populatedTestValue, name: "Run AppleScript", isSharedContext: true, contextName: "MyContext")
    static let emptyTestValue = Self(objectID: nil, name: nil, isSharedContext: false, contextName: "")
}

extension XCSchema.CopyFilesBuildPhaseProperties: TestInstanceDefining {
    static let populatedTestValue = Self(objectID: .populatedTestValue, name: "Copy Files", bundleBasePath: .resourcesDir, relativePath: "Subfolder", scope: .install)
    static let emptyTestValue = Self(objectID: nil, name: nil, bundleBasePath: nil, relativePath: "", scope: .always)
}

extension XCSchema.ScriptBuildPhaseProperties: TestInstanceDefining {
    static let populatedTestValue = Self(objectID: .populatedTestValue, name: "Run Script", shellPath: "/bin/sh", script: "echo hello", logEnvironmentVariables: true, inputPaths: ["$(SRCROOT)/in.txt"], inputFileListPaths: ["$(SRCROOT)/in.xcfilelist"], outputPaths: ["$(DERIVED_FILE_DIR)/out.txt"], outputFileListPaths: ["$(DERIVED_FILE_DIR)/out.xcfilelist"], dependencyFile: "$(DERIVED_FILE_DIR)/deps.d", runOnEveryBuild: true, scope: .install)
    static let emptyTestValue = Self(objectID: nil, name: "", shellPath: "", script: "", logEnvironmentVariables: false, inputPaths: [], inputFileListPaths: [], outputPaths: [], outputFileListPaths: [], dependencyFile: nil, runOnEveryBuild: false, scope: .always)
    static let additionalTestValues: [Self] = [
        populatedTestValue.copy(with: \.script, "echo hello"),
        populatedTestValue.copy(with: \.script, "echo \"hello\""),
        populatedTestValue.copy(with: \.script, "echo \"hello\"\n"),
        populatedTestValue.copy(with: \.script, "echo \"hello\"\n\n"),
        populatedTestValue.copy(with: \.script, "echo \"hello\"\nexit -1\n"),
    ]
}

extension XCSchema.BuildPhase: TestInstanceDefining {
    static let populatedTestValue = Self.script(.populatedTestValue)
    static let emptyTestValue = Self.sources(.emptyTestValue)
    static let additionalTestValues: [Self] = [
        .frameworks(.populatedTestValue),
        .headers(.populatedTestValue),
        .javaArchive(.populatedTestValue),
        .resources(.populatedTestValue),
        .rez(.populatedTestValue),
        .sources(.populatedTestValue),
        .appleScript(.populatedTestValue),
        .copy(.populatedTestValue),
        .script(.populatedTestValue),

        .frameworks(.emptyTestValue),
        .headers(.emptyTestValue),
        .javaArchive(.emptyTestValue),
        .resources(.emptyTestValue),
        .rez(.emptyTestValue),
        .sources(.emptyTestValue),
        .appleScript(.emptyTestValue),
        .copy(.emptyTestValue),
        .script(.emptyTestValue),

        .frameworks(.defaultInstance),
        .headers(.defaultInstance),
        .javaArchive(.defaultInstance),
        .resources(.defaultInstance),
        .rez(.defaultInstance),
        .sources(.defaultInstance),
    ]
}

extension XCSchema.RemoteProduct: TestInstanceDefining {
    static let populatedTestValue = Self(project: .populatedTestValue, target: "MyFramework", productID: .populatedTestValue, path: "MyFramework.framework", fileType: .populatedTestValue, buildFiles: [.populatedTestValue])
    static let emptyTestValue = Self(project: .emptyTestValue, target: "", productID: .emptyTestValue, path: "", fileType: .emptyTestValue, buildFiles: [])
}

extension XCSchema.BuildRule: TestInstanceDefining {
    static let populatedTestValue = Self(objectID: .populatedTestValue, processor: "sh", name: "Custom Rule", fileType: .populatedTestValue, filePatterns: "*.swift", script: "swiftc $INPUT_FILE_PATH", inputFiles: ["$(SRCROOT)/in.swift"], inputFileLists: ["$(SRCROOT)/in.xcfilelist"], outputFiles: ["$(DERIVED_FILE_DIR)/out.o"], outputFileLists: ["$(DERIVED_FILE_DIR)/out.xcfilelist"], outputFilesCompilerFlags: ["-O"], dependencyFile: "$(DERIVED_FILE_DIR)/deps.d", runOncePerArchitecture: true)
    static let emptyTestValue = Self(objectID: nil, processor: "", name: nil, fileType: nil, filePatterns: nil, script: nil, inputFiles: [], inputFileLists: [], outputFiles: [], outputFileLists: [], outputFilesCompilerFlags: [], dependencyFile: nil, runOncePerArchitecture: false)
    static let additionalTestValues: [Self] = [
        populatedTestValue.copy(with: \.script, "echo hello"),
        populatedTestValue.copy(with: \.script, "echo \"hello\""),
        populatedTestValue.copy(with: \.script, "echo \"hello\"\n"),
        populatedTestValue.copy(with: \.script, "echo \"hello\"\n\n"),
        populatedTestValue.copy(with: \.script, "echo \"hello\"\nexit -1\n"),
    ]
}

extension XCSchema.Capability: TestInstanceDefining {
    static let populatedTestValue = Self.knownCapabilityForTesting
    static let emptyTestValue = Self(capabilityDescription: "")
}

extension XCSchema.ConfigurationName: TestInstanceDefining {
    static let populatedTestValue = Self(name: "Debug")
    static let emptyTestValue = Self(name: "")
}

extension XCSchema.Language: TestInstanceDefining {
    static let populatedTestValue = Self(languageID: "en")
    static let emptyTestValue = Self(languageID: "")
}

extension XCSchema.FileTypeID: TestInstanceDefining {
    static let populatedTestValue = Self(fileTypeID: "sourcecode.swift")
    static let emptyTestValue = Self(fileTypeID: "")
}

extension XCSchema.GroupTreeReference: TestInstanceDefining {
    static let populatedTestValue = Self.namePath(.populatedTestValue)
    static let emptyTestValue = Self.namePath(.emptyTestValue)
    static let additionalTestValues: [Self] = [
        .objectID(.populatedTestValue),
    ] + XCSchema.NamePath.additionalTestValues.map(Self.namePath)

}


extension XCSchema.GroupTreeAnchoredReference: TestInstanceDefining {
    static let populatedTestValue = Self(anchor: .populatedTestValue, relativePath: .populatedTestValue)
    static let emptyTestValue = Self(anchor: .emptyTestValue, relativePath: nil)
    static let additionalTestValues: [Self] = [
        Self(anchor: .emptyTestValue, relativePath: .emptyTestValue)
    ]
}

extension XCSchema.LocalTargetReference: TestInstanceDefining {
    static let populatedTestValue = Self(targetName: "App")
    static let emptyTestValue = Self(targetName: "")
}

extension XCSchema.NamePath: TestInstanceDefining {
    static let populatedTestValue = Self(components: [
        .relative(.parent), .child("Sources"), .child("Foo.swift"),
    ])
    static let emptyTestValue = Self(components: [])

    static var additionalTestValues: [Self] {
        let components: [XCSchema.NamePathComponent] = [
            .relative(.current),
            .relative(.parent),
            .child("item"),
            .child(".."),
            .child("."),
            .child("/"),
            .child(""),
        ]

        var paths: [Self] = []
        components.enumerateAllSubsetsInExponentialTime { subset in
            subset.enumeratePermutationsInFactorialTime { subsetPermutation in
                paths.append(.init(components: subsetPermutation))
            }
        }
        return paths
    }
}

extension XCSchema.NamePathComponent: TestInstanceDefining {
    static let populatedTestValue = Self.relative(.parent)
    static let emptyTestValue = Self.child("")
    static let additionalTestValues: [Self] = [
        .child(""),
        .child("Asdf"),
        .relative(.current),
        .relative(.parent),
    ]
}

extension XCSchema.PlatformFilter: TestInstanceDefining {
    static let populatedTestValue = Self(platformID: "ios")
    static let emptyTestValue = Self(platformID: "")
}

extension XCSchema.ProductTypeID: TestInstanceDefining {
    static let populatedTestValue = Self(productTypeID: "com.apple.product-type.application")
    static let emptyTestValue = Self(productTypeID: "")
}

extension XCSchema.BuildSetting: TestInstanceDefining {
    static let populatedTestValue = Self.string("Setting")
    static let emptyTestValue = Self.array([])
    static let additionalTestValues: [Self] = [
        .string(""),
        .array(["String"]),
        .array(["A", "B"]),
    ]
}

extension XCSchema.Project: TestInstanceDefining {
    static let populatedTestValue = Self(objectID: .populatedTestValue, rootGroupDebugID: .populatedTestValue, configurationListDebugID: .populatedTestValue, topLevelReferences: [.populatedTestValue], packages: [.populatedTestValue], configurations: [.populatedTestValue, .emptyTestValue], buildSettings: ["SDKROOT": .populatedTestValue], defaultConfigurationName: .populatedTestValue, targets: [.populatedTestValue], localizationInfo: .populatedTestValue, requiredCapabilities: [.populatedTestValue], buildIndependentTargetsInParallel: true, lastUpgradeCheck: .populatedTestValue, lastSwiftUpdateCheck: .populatedTestValue, lastSwiftMigration: .populatedTestValue, organizationName: "example.com", classPrefix: "EX", productsGroup: .populatedTestValue, importedProducts: [.populatedTestValue])
    static let emptyTestValue = Self(objectID: nil, rootGroupDebugID: nil, configurationListDebugID: nil, topLevelReferences: [], packages: [], configurations: [], buildSettings: [:], defaultConfigurationName: .emptyTestValue, targets: [], localizationInfo: .emptyTestValue, requiredCapabilities: [], buildIndependentTargetsInParallel: false, lastUpgradeCheck: nil, lastSwiftUpdateCheck: nil, lastSwiftMigration: nil, organizationName: nil, classPrefix: nil, productsGroup: nil, importedProducts: [])
}

extension XCSchema.ProjectLocalizationInfo: TestInstanceDefining {
    static let populatedTestValue = Self(development: .init(languageID: "en"), supported: [.init(languageID: "Base")])
    static let emptyTestValue = Self(development: .init(languageID: "en"), supported: [])
}

extension XCSchema.RemoteTarget: TestInstanceDefining {
    static let populatedTestValue = Self(project: .populatedTestValue, target: "OtherTarget", targetID: .populatedTestValue)
    static let emptyTestValue = Self(project: .emptyTestValue, target: "", targetID: .emptyTestValue)
}

extension XCSchema.SwiftPackageLocation: TestInstanceDefining {
    static let populatedTestValue = Self.remote(.populatedTestValue)
    static let emptyTestValue = Self.local(.emptyTestValue)
}

extension XCSchema.SwiftPackageName: TestInstanceDefining {
    static let populatedTestValue = Self(packageName: "SuperUseful")
    static let emptyTestValue = Self(packageName: "")
}

extension XCSchema.SwiftPackageProductReference: TestInstanceDefining {
    static let populatedTestValue = Self(objectID: .populatedTestValue, package: .populatedTestValue, productName: "helper", productType: .populatedTestValue)
    static let emptyTestValue = Self(objectID: nil, package: .emptyTestValue, productName: "", productType: .emptyTestValue)
}

extension XCSchema.SwiftPackageProductType: TestInstanceDefining {
    static let populatedTestValue = Self.buildToolPlugin
    static let emptyTestValue = Self.other
}

extension XCSchema.LocalSwiftPackage: TestInstanceDefining {
    static let populatedTestValue = Self(path: "./LocalPackage")
    static let emptyTestValue = Self(path: "")
}

extension XCSchema.RemoteSwiftPackage: TestInstanceDefining {
    static let populatedTestValue = Self(repositoryURL: "https://github.com/example/Package.git", versionConstraint: .populatedTestValue)
    static let emptyTestValue = Self(repositoryURL: "", versionConstraint: nil)
}

extension XCSchema.SwiftPackageVersionConstraint: TestInstanceDefining {
    static let populatedTestValue = Self.upToNextMajorVersion("1.4")
    static let emptyTestValue = Self.branch("")
    static let additionalTestValues: [Self] = [
        .revision("1"),
        .branch("2"),
        .version("3"),
        .versionRange(min: "4", max: "5"),
        .upToNextMinorVersion("6"),
        .upToNextMajorVersion("7"),
    ]
}

extension XCSchema.SwiftPackage: TestInstanceDefining {
    static let populatedTestValue = Self(location: .remote(.populatedTestValue), traits: [])
    static let emptyTestValue = Self(location: .local(.emptyTestValue), traits: [])
}

extension XCSchema.Target.Kind: TestInstanceDefining {
    static let populatedTestValue = Self.native
    static let emptyTestValue = Self.aggregate
}

extension XCSchema.LegacyProvisioningStyle: TestInstanceDefining {
    static let populatedTestValue = Self.automatic
    static let emptyTestValue = Self.manual
}

extension XCSchema.Target: TestInstanceDefining {
    static let populatedTestValue = Self.native(.populatedTestValue)
    static let emptyTestValue = Self.aggregate(.populatedTestValue)
    static let additionalTestValues: [Self] = [
        Self.externalBuildSystem(.populatedTestValue)
    ]
}

extension XCSchema.CommonTargetProperties: TestInstanceDefining {
    static let populatedTestValue = Self(name: "App", objectID: .populatedTestValue, configurationListDebugID: .populatedTestValue, dependencies: [.populatedTestValue], buildPhases: [.populatedTestValue], buildRules: [.populatedTestValue], specializedConfigurations: [.populatedTestValue, .populatedTestValue], buildSettings: ["SWIFT_VERSION": .populatedTestValue], product: nil, productTypeID: .populatedTestValue, testHostTarget: .populatedTestValue, legacyProvisioningStyle: .populatedTestValue, legacyTeamID: "MyTeamID", lastSwiftUpdateCheck: .populatedTestValue, lastSwiftMigration: .populatedTestValue, packageProductTargetMembers: [.populatedTestValue])
    static let emptyTestValue = Self(name: "", objectID: .emptyTestValue, configurationListDebugID: nil, dependencies: [.emptyTestValue], buildPhases: [.emptyTestValue], buildRules: [.emptyTestValue], specializedConfigurations: [], buildSettings: [:], product: nil, productTypeID: nil, testHostTarget: nil, legacyProvisioningStyle: nil, legacyTeamID: nil, lastSwiftUpdateCheck: nil, lastSwiftMigration: nil, packageProductTargetMembers: [])
    static let additionalTestValues: [Self] = [
        Self.emptyTestValue.copy(with: \.productTypeID, XCSchema.ProductTypeID(productTypeID: "unusual.prefix")),
        Self.emptyTestValue.copy(with: \.productTypeID, XCSchema.ProductTypeID(abbreviatedRepresentation: "app")),
        Self.emptyTestValue.copy(with: \.productTypeID, nil),
    ]
}

extension XCSchema.ExternalBuildSystemTargetProperties: TestInstanceDefining {
    static let populatedTestValue = Self(commonProperties: .populatedTestValue, buildToolPath: "/usr/bin/external-tool", buildToolArguments: "--glow-in-the-dark true", buildToolWorkingDirectory: "/shared/build", passBuildSettingsInEnvironment: true)
    static let emptyTestValue = Self(commonProperties: .emptyTestValue, buildToolPath: "", buildToolArguments: "", buildToolWorkingDirectory: nil, passBuildSettingsInEnvironment: false)
    static let additionalTestValues: [Self] = [
        Self.emptyTestValue.copy(with: \.buildToolWorkingDirectory, ""),
    ]
}

extension XCSchema.SwiftPackageProductTargetMember: TestInstanceDefining {
    static let populatedTestValue = Self(packageProduct: .populatedTestValue, buildFile: .populatedTestValue)
    static let emptyTestValue = Self(packageProduct: .emptyTestValue, buildFile: .emptyTestValue)
}

extension XCSchema.TargetDependency: TestInstanceDefining {
    static let populatedTestValue = Self.remoteTarget(.populatedTestValue, [.populatedTestValue])
    static let emptyTestValue = Self.localTarget(.emptyTestValue, [])
    static let additionalTestValues: [Self] = [
        .localTarget(.populatedTestValue, [.populatedTestValue]),
        .remoteTarget(.populatedTestValue, [.populatedTestValue]),
        .package(.populatedTestValue, [.populatedTestValue]),
        .localTarget(.populatedTestValue, []),
        .remoteTarget(.populatedTestValue, []),
        .package(.populatedTestValue, []),
    ]
}

extension XCSchema.FileReference: TestInstanceDefining {
    static let populatedTestValue = Self(objectID: .populatedTestValue, path: .populatedTestValue, explicitFileType: .populatedTestValue, expectedSignature: "abc123", textEncoding: .populatedTestValue, lineEnding: .populatedTestValue, includeInIndex: true, buildFiles: [.populatedTestValue])
    static let emptyTestValue = Self(objectID: nil, path: .emptyTestValue, explicitFileType: nil, expectedSignature: nil, textEncoding: nil, lineEnding: nil, includeInIndex: nil, buildFiles: [])
}

extension XCSchema.LineEnding: TestInstanceDefining {
    static let populatedTestValue = Self.lineFeed
    static let emptyTestValue = Self.preserve
    static let additionalTestValues: [Self] = [
        .lineFeed,
        .carriageReturn,
        .carriageReturnLineFeed,
        .preserve,
    ]
}

extension XCSchema.TextEncoding: TestInstanceDefining {
    static let populatedTestValue = Self(rawValue: .utf8)
    static let emptyTestValue = Self(rawValue: .ascii)
}

extension XCSchema.ProjectBuildPhaseReference: TestInstanceDefining {
    static let populatedTestValue = Self.named(target: .populatedTestValue, kind: .script, name: "Install man pages")
    static let emptyTestValue = Self.named(target: .emptyTestValue, kind: .sources, name: nil)
}

extension XCSchema.TargetBuildPhaseReference: TestInstanceDefining {
    static let populatedTestValue = Self.named(kind: .copy, name: "Install man pages")
    static let emptyTestValue = Self.named(kind: .headers, name: nil)
}

extension XCSchema.BuildPhaseExceptionSet: TestInstanceDefining {
    static let populatedTestValue = Self(buildPhase: .populatedTestValue, commonProperties: .populatedTestValue)
    static let emptyTestValue = Self(buildPhase:.emptyTestValue, commonProperties: .emptyTestValue)
}

extension XCSchema.CommonExceptionSetProperties: TestInstanceDefining {
    static let populatedTestValue = Self(sense: .exclusions, membershipExceptions: ["File1.swift"], platformFiltersByFolderMemberID: ["File1.swift": [.populatedTestValue]], attributesByFolderMemberID: ["File1.swift": .populatedTestValue], assetTagsByFolderMemberID: ["File1.swift": [.populatedTestValue]])
    static let emptyTestValue = Self(sense: .inclusions, membershipExceptions: [], platformFiltersByFolderMemberID: [:], attributesByFolderMemberID: [:], assetTagsByFolderMemberID: [:])
}

extension XCSchema.FolderExceptionSet: TestInstanceDefining {
    static let populatedTestValue = Self.buildPhase(.populatedTestValue)
    static let emptyTestValue = Self.target(.emptyTestValue)
}

extension XCSchema.TargetExceptionSet: TestInstanceDefining {
    static let populatedTestValue = Self(target: .populatedTestValue, publicHeaders: ["Foo.h"], privateHeaders: ["Bar.h"], additionalCompilerFlags: ["Foo.h": "-O"], commonProperties: .populatedTestValue)
    static let emptyTestValue = Self(target: .emptyTestValue, publicHeaders: [], privateHeaders: [], additionalCompilerFlags: [:], commonProperties: .emptyTestValue)
}

extension XCSchema.Folder: TestInstanceDefining {
    static let populatedTestValue = Self(objectID: .populatedTestValue, path: .populatedTestValue, targets: [.populatedTestValue], membershipExceptions: [.target(.populatedTestValue)], explicitFileTypes: ["File1.swift": .populatedTestValue], explicitOpaqueFolders: ["OpaqueFolder"], includeInIndex: true)
    static let emptyTestValue = Self(objectID: .populatedTestValue, path: .emptyTestValue, targets: [], membershipExceptions: [], explicitFileTypes: [:], explicitOpaqueFolders: [], includeInIndex: nil)
}

extension XCSchema.FolderMemberID: TestInstanceDefining {
    static let populatedTestValue = Self(value: "Sources/Foo.swift")
    static let emptyTestValue = Self(value: "")
}

extension XCSchema.Group: TestInstanceDefining {
    static let populatedTestValue = Self(objectID: .populatedTestValue, name: "Sources", path: .populatedTestValue, includeInIndex: true, children: [.fileReference(.populatedTestValue)])
    static let emptyTestValue = Self(objectID: nil, name: "", path: .emptyTestValue, includeInIndex: nil, children: [])
}

extension XCSchema.VariantGroup: TestInstanceDefining {
    static let populatedTestValue = Self(objectID: .populatedTestValue, name: "Variants", path: .populatedTestValue, includeInIndex: true, buildFiles: [.populatedTestValue], children: [.populatedTestValue])
    static let emptyTestValue = Self(objectID: nil, name: "", path: .emptyTestValue, includeInIndex: nil, buildFiles: [], children: [])
}

extension XCSchema.VersionGroup: TestInstanceDefining {
    static let populatedTestValue = Self(objectID: .populatedTestValue, name: "Model", path: .populatedTestValue, currentVersion: .populatedTestValue, versionedFileType: .populatedTestValue, includeInIndex: true, buildFiles: [.populatedTestValue], children: [.populatedTestValue])
    static let emptyTestValue = Self(objectID: nil, name: "", path: .emptyTestValue, currentVersion: nil, versionedFileType: nil, includeInIndex: nil, buildFiles: [], children: [])
}

extension XCSchema.FilePath: TestInstanceDefining {
    static let populatedTestValue = try! Self(base: .absolute, path: "/Sources/Foo.swift")
    static let emptyTestValue = try! Self(base: .group, path: "")

    static let additionalTestValues: [Self] = {
        let relativeBases: [Base] = [
            .group,
            .project,
            .developer,
            .buildProducts,
            .sdk,
        ]

        var testCases: [Self] = []
        var testPathFramgents = ["/", "A", "B", "<", ">", "USER", "\\"]
        testPathFramgents.enumerateAllSubsetPermutationJoinings { path in
            if !path.hasPrefix("/") && !path.hasPrefix("~") {
                for relativeBase in relativeBases {
                    try! testCases.append(Self(base: relativeBase, path: path))
                }
                try! testCases.append(Self(base: .sourceRoot(path), path: path))
            }
        }
        testPathFramgents.enumerateAllSubsetPermutationJoinings { path in
            try! testCases.append(Self(base: .absolute, path: "/" + path))
        }
        try! testCases.append(Self(base: .absolute, path: "~"))
        try! testCases.append(Self(base: .absolute, path: "~/Sources/Foo.swift"))
        try! testCases.append(Self(base: .absolute, path: "~user/file.swift"))
        return testCases
    }()
}

extension XCSchema.Reference: TestInstanceDefining {
    static let populatedTestValue = Self.fileReference(.populatedTestValue)
    static let emptyTestValue = Self.group(.emptyTestValue)
    static let additionalTestValues: [Self] = [
        .fileReference(.populatedTestValue),
        .group(.populatedTestValue),
        .folder(.populatedTestValue),
        .variantGroup(.populatedTestValue),
        .versionGroup(.populatedTestValue),
    ]
}

extension XCSchema.BuildFileAttributes.HeaderPreservation: TestInstanceDefining {
    static let populatedTestValue = Self.removeOnCopy
    static let emptyTestValue = Self.keep
    static let additionalTestValues: [Self] = [
        .keep,
        .removeOnCopy,
    ]
}

extension XCSchema.BuildFileAttributes.HeaderRole: TestInstanceDefining {
    static let populatedTestValue: Self = .public
    static let emptyTestValue: Self = .private
    static let additionalTestValues: [Self] = [
        .public,
        .private,
    ]
}

extension XCSchema.BuildFileAttributes.MachInterfaceGeneration: TestInstanceDefining {
    static let populatedTestValue: Self = .server
    static let emptyTestValue: Self = .client
    static let additionalTestValues: [Self] = [
        .client,
        .server,
        .both,
    ]
}

extension XCSchema.BuildFileAttributes.CodeGenerationVisibility: TestInstanceDefining {
    static let populatedTestValue: Self = .public
    static let emptyTestValue: Self = .project
    static let additionalTestValues: [Self] = [
        .public,
        .private,
        .project,
    ]
}

extension XCSchema.BuildFileAttributes.CodeGeneration: TestInstanceDefining {
    static let populatedTestValue: Self = .skip
    static let emptyTestValue: Self = .default
    static let additionalTestValues: [Self] = [
        .default,
        .skip
    ]
}

extension XCSchema.BuildPhaseScope: TestInstanceDefining {
    static let populatedTestValue: Self = .install
    static let emptyTestValue: Self = .always
    static let additionalTestValues: [Self] = [
        .always,
        .install,
    ]
}

extension XCSchema.BuildPhase.Kind: TestInstanceDefining {
    static let populatedTestValue: Self = .frameworks
    static let emptyTestValue: Self = .script
    static let additionalTestValues: [Self] = [
        .appleScript,
        .frameworks,
        .headers,
        .javaArchive,
        .resources,
        .rez,
        .sources,
        .copy,
        .script,
    ]
}

extension XCSchema.Reference.Kind: TestInstanceDefining {
    static let populatedTestValue: Self = .fileReference
    static let emptyTestValue: Self = .group
    static let additionalTestValues: [Self] = [
        .fileReference,
        .group,
        .folder,
        .variantGroup,
        .versionGroup,
    ]
}

extension XCSchema.BundleBasePath: TestInstanceDefining {
    static let populatedTestValue: Self = .sharedFrameworksDir
    static let emptyTestValue: Self = .root
    static let additionalTestValues: [Self] = [
        .root,
        .productDir,
        .sharedFrameworksDir,
        .sharedSupportDir,
        .javaDir,
        .frameworksDir,
        .resourcesDir,
        .pkgInfo,
        .appleScriptsDir,
        .plugInsDir,
        .privateHeadersDir,
        .headersDir,
        .contentsDir,
        .executablesDir,
        .infoPlist,
        .mainExecutable,
        .mainExecutableShallow,
    ]
}

extension XCSchema.MultilineText: TestInstanceDefining {
    static let populatedTestValue: Self = Self(text: "#!/usr/bin/sh\necho \"Hello World\"\n")
    static let emptyTestValue: Self = Self(text: "")
    static let additionalTestValues: [Self] = [
        Self(text: ""),
        Self(text: "\n"),
        Self(text: "\n\n"),
        Self(text: "\n\n\n"),
    ]
}

extension XCSchema.MarketingVersion: TestInstanceDefining {
    static let populatedTestValue: Self = Self(major: 27, minor: 1, update: 2)
    static let emptyTestValue: Self = Self(major: 27, minor: 0, update: 0)
    static let additionalTestValues: [Self] = [
        Self(major: 0, minor: 0, update: 0),
        Self(major: 1, minor: 0, update: 0),
    ]
}
