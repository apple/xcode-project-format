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

struct TestStringEscapingDuringEncoding {
    @Test func testStringEncoding() {
        let encodings: [String.Encoding] = [
            .ascii,
            .nextstep,
            .japaneseEUC,
            .utf8,
            .isoLatin1,
            .symbol,
            .nonLossyASCII,
            .shiftJIS,
            .isoLatin2,
            .unicode,
            .windowsCP1251,
            .windowsCP1252,
            .windowsCP1253,
            .windowsCP1254,
            .windowsCP1250,
            .iso2022JP,
            .macOSRoman,
            .utf16,
            .utf16BigEndian,
            .utf16LittleEndian,
            .utf32,
            .utf32BigEndian,
            .utf32LittleEndian,
            .init(rawValue: 23418341), // Unknown values are persisted
        ]
        for encoding in encodings {
            expectRoundTripEqual(XCSchema.TextEncoding(rawValue: encoding))
        }
    }

    @Test func testBuildPhaseReference() {
        let hardStrings = [
            "",
            "/",
            "a",
            "b",
        ]

        expectRoundTripEqual(XCSchema.TargetBuildPhaseReference.named(kind: .copy, name: nil))
        hardStrings.enumerateAllSubsetPermutationJoinings { hardString in
            expectRoundTripEqual(XCSchema.TargetBuildPhaseReference.named(kind: .copy, name: hardString))
        }

        hardStrings.enumerateAllSubsetPermutationJoinings { targetName in
            expectRoundTripEqual(XCSchema.ProjectBuildPhaseReference.named(target: XCSchema.LocalTargetReference(targetName: targetName), kind: .copy, name: nil))
            hardStrings.enumerateAllSubsetPermutationJoinings { buildPhaseName in
                expectRoundTripEqual(XCSchema.ProjectBuildPhaseReference.named(target: XCSchema.LocalTargetReference(targetName: targetName), kind: .copy, name: buildPhaseName))
            }
        }
    }

    @Test func testSwiftPackageVersionConstraints() {
        let hardStrings = [
            ".",
            "..",
            "1",
            "<",
            "2",
        ]
        func test(_ hardString: String) {
            expectRoundTripEqual(SwiftPackageVersionConstraint.revision(hardString))
            expectRoundTripEqual(SwiftPackageVersionConstraint.branch(hardString))
            expectRoundTripEqual(SwiftPackageVersionConstraint.version(hardString))
            expectRoundTripEqual(SwiftPackageVersionConstraint.versionRange(min: hardString, max: hardString))
            expectRoundTripEqual(SwiftPackageVersionConstraint.upToNextMinorVersion(hardString))
            expectRoundTripEqual(SwiftPackageVersionConstraint.upToNextMajorVersion(hardString))
        }

        hardStrings.enumerateAllSubsetPermutationJoinings { hardString in
            test(hardString)
        }
    }

    @Test func testFilePaths() {
        func expect(_ base: XCSchema.FilePath.Base, _ path: String) {
            do {
                expectRoundTripEqual(try FilePath(base: base, path: path))
            } catch {
                Issue.record(error)
            }
        }

        expect(.sourceRoot(XCSchema.FilePath.Base.buildProducts.builtInExpansionVariable!), "")
        expect(.sourceRoot(""), "")
        expect(.sourceRoot("$"), "")
        expect(.sourceRoot("$a"), "")
        expect(.sourceRoot("$()"), "")
        expect(.sourceRoot("$asdf"), "")
        expect(.sourceRoot("$(asdf)"), "")

        expect(.project, "")
        expect(.project, ".")
        expect(.project, "..")
        expect(.project, "./")

        expect(.absolute, "/")
        expect(.absolute, "/.")
        expect(.absolute, "/..")
        expect(.absolute, "~")
        expect(.absolute, "~/.")
        expect(.absolute, "~user")

        expect(.project, "")

        expect(.group, "")
        expect(.group, "$")
        expect(.group, "$a")
        expect(.group, "$()")
        expect(.group, "$asdf")
        expect(.group, "$(asdf)")

        let hardStrings = [
            "$",
            "(",
            ")",
            "a",
        ]

        hardStrings.enumerateAllSubsetPermutationJoinings { hardString in
            expect(.group, hardString)
        }
    }

    @Test func testNamePaths() {
        //expectRoundTripEqual(NamePath(components: []))

        let hardStrings = [
            "a",
            "",
            "/",
            "//",
            ".",
            "..",
        ]

        hardStrings.enumerateAllSubsetPermutationJoinings { hardString in
            expectRoundTripEqual(NamePath(components: [.child(hardString)]))
        }

        // Too Slow.
        // let hardComponents = hardStrings.map(NamePathComponent.child) + [.relative(.current), .relative(.parent)]
        //
        // hardComponents.enumerateAllSubsetsInExponentialTime { hardStringsSubset in
        //     hardComponents.enumeratePermutationsInFactorialTime { perumation in
        //         expectRoundTripEqual(NamePath(components: perumation))
        //     }
        // }
    }
}
