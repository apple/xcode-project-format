//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import XcodeProjectFormat
import Testing

struct RoundTripSomeOfEverythingTests {
    @Test func roundTrippingEmptyAndPopulatedTypes() {
        func test<T: TestInstanceDefining & Equatable & XCJSON.Codable>(_ type: T.Type) {
            expectRoundTripEqual(type.populatedTestValue)
            expectRoundTripEqual(type.emptyTestValue)
            for instance in type.additionalTestValues {
                expectRoundTripEqual(instance)
            }
        }

        test(XCSchema.AppleScriptBuildPhaseProperties.self)
        test(XCSchema.AssetTag.self)
        test(XCSchema.BuildFileAttributes.CodeGeneration.self)
        test(XCSchema.BuildFileAttributes.CodeGenerationVisibility.self)
        test(XCSchema.BuildFileAttributes.HeaderPreservation.self)
        test(XCSchema.BuildFileAttributes.HeaderRole.self)
        test(XCSchema.BuildFileAttributes.MachInterfaceGeneration.self)
        test(XCSchema.BuildFileAttributes.self)
        test(XCSchema.BuildFileProperties.self)
        test(XCSchema.BuildPhase.Kind.self)
        test(XCSchema.BuildPhase.self)
        test(XCSchema.BuildPhaseExceptionSet.self)
        test(XCSchema.BuildPhaseProperties.self)
        test(XCSchema.BuildPhaseScope.self)
        test(XCSchema.BuildRule.self)
        test(XCSchema.BuildSetting.self)
        test(XCSchema.BundleBasePath.self)
        test(XCSchema.Capability.self)
        test(XCSchema.CommonExceptionSetProperties.self)
        test(XCSchema.Configuration.self)
        test(XCSchema.ConfigurationName.self)
        test(XCSchema.CopyFilesBuildPhaseProperties.self)
        test(XCSchema.Language.self)
        test(XCSchema.FilePath.self)
        test(XCSchema.FileReference.self)
        test(XCSchema.FileTypeID.self)
        test(XCSchema.Folder.self)
        test(XCSchema.FolderExceptionSet.self)
        test(XCSchema.FolderMemberID.self)
        test(XCSchema.Group.self)
        test(XCSchema.GroupTreeAnchoredReference.self)
        test(XCSchema.GroupTreeReference.self)
        test(XCSchema.LegacyProvisioningStyle.self)
        test(XCSchema.LineEnding.self)
        test(XCSchema.LocalSwiftPackage.self)
        test(XCSchema.LocalTargetReference.self)
        test(XCSchema.MarketingVersion.self)
        test(XCSchema.MultilineText.self)
        test(XCSchema.NamePath.self)
        test(XCSchema.NamePathComponent.self)
        test(XCSchema.ObjectID.self)
        test(XCSchema.PlatformFilter.self)
        test(XCSchema.ProductTypeID.self)
        test(XCSchema.Project.self)
        test(XCSchema.ProjectBuildFile.self)
        test(XCSchema.ProjectBuildFile.self)
        test(XCSchema.ProjectBuildPhaseReference.self)
        test(XCSchema.ProjectLocalizationInfo.self)
        test(XCSchema.Reference.Kind.self)
        test(XCSchema.Reference.self)
        test(XCSchema.RemoteProduct.self)
        test(XCSchema.RemoteSwiftPackage.self)
        test(XCSchema.RemoteTarget.self)
        test(XCSchema.ScriptBuildPhaseProperties.self)
        test(XCSchema.SwiftPackage.self)
        test(XCSchema.SwiftPackageLocation.self)
        test(XCSchema.SwiftPackageName.self)
        test(XCSchema.SwiftPackageProductReference.self)
        test(XCSchema.SwiftPackageProductTargetMember.self)
        test(XCSchema.SwiftPackageProductType.self)
        test(XCSchema.SwiftPackageVersionConstraint.self)
        test(XCSchema.Target.Kind.self)
        test(XCSchema.Target.self)
        test(XCSchema.ExternalBuildSystemTargetProperties.self)
        test(XCSchema.TargetBuildFile.self)
        test(XCSchema.TargetBuildPhaseReference.self)
        test(XCSchema.TargetDependency.self)
        test(XCSchema.TargetExceptionSet.self)
        test(XCSchema.TextEncoding.self)
        test(XCSchema.VariantGroup.self)
        test(XCSchema.VersionGroup.self)
    }
}
