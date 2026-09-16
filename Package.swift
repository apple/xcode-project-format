// swift-tools-version: 6.1
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
