// swift-tools-version: 6.1

//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0 with Runtime Library Exception
// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
//
//===----------------------------------------------------------------------===//

import PackageDescription

let package = Package(
    name: "xcode-project-format",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(
            name: "XcodeProjectFormat",
            targets: ["XcodeProjectFormat"]
        ),
        .executable(
            name: "xcprojformatter",
            targets: ["XcodeProjectTool"]
        ),
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "XcodeProjectTool",
            dependencies: ["XcodeProjectFormat"],
            path: "Sources/Tool",
        ),
        .target(
            name: "XcodeProjectFormat",
            dependencies: [],
            path: "Sources/Library",
        ),
        .testTarget(
            name: "XcodeProjectFormatTests",
            dependencies: ["XcodeProjectFormat"],
            path: "Sources/Tests",
            swiftSettings: [
                .define("ENABLE_PERFORMANCE_TESTS", .when(configuration: .release)),
            ],
        ),
        .testTarget(
            name: "XcodeProjectToolTests",
            dependencies: ["XcodeProjectTool", "XcodeProjectFormat"],
            path: "Sources/ToolTests",
            resources: [
                .copy("Fixtures"),
            ],
        ),
    ],
    swiftLanguageModes: [.v6],
)

for target in package.targets {
    target.swiftSettings = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("ImmutableWeakCaptures"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    ]
}
