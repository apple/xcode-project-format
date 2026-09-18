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

extension TimeInterval {
    fileprivate func formattedSeconds() -> String {
        String(format: "%03.4f", self)
    }
}

#if ENABLE_PERFORMANCE_TESTS
let performanceTestsAreEnabledForBuildConfiguration = true
#else
let performanceTestsAreEnabledForBuildConfiguration = false
#endif

/// Performance tests only run in release builds, and only against a corpus of real
/// `.xcproj` files supplied via `XC_PROJECT_FORMAT_TEST_PROJECT_SOURCE_DIR`.
let performanceTestsAreRunnable = performanceTestsAreEnabledForBuildConfiguration && (SampleData.sourceDirectory != nil)

@Suite(.enabled(if: performanceTestsAreRunnable, "Performance tests require a release build and a directory of sample projects in \(SampleData.sourceDirectoryEnvironmentVariable)."))
struct TestPerformance {
    func measureTransformingSampleProjectData<Result>(testName: String = #function, body: (SampleData.Record) throws -> Result) throws {
        let sampleData = try SampleData.sharedInstance.get()
        let testDurations = try Array(repetitions: 100) {
            try measureDuration {
                for record in sampleData.records {
                    try blackhole(body(record))
                }
            }
        }
        let min = testDurations.min()
        let max = testDurations.max()
        let mean = testDurations.mean()
        let median = testDurations.median()
        let total = testDurations.sum()
        print("Performance test complete: \(testName)")
        print("     min: \(min?.formattedSeconds() ?? "N/A")")
        print("     max: \(max?.formattedSeconds() ?? "N/A")")
        print("    mean: \(mean?.formattedSeconds() ?? "N/A")")
        print("  median: \(median?.formattedSeconds() ?? "N/A")")
        print("   total: \(total.formattedSeconds())")
    }

    @Test func testAnyJSONSerializationInstantiationPerformance() throws {
        try measureTransformingSampleProjectData { record in
            try JSONSerialization.jsonObject(with: record.data)
        }
    }

    @Test func testXCJSONInstantiationPerformance() throws {
        try measureTransformingSampleProjectData { record in
            try XCJSON.Value(data: record.data)
        }
    }

    @Test func testIsolatedProjectDecodingPerformance() throws {
        try measureTransformingSampleProjectData { record in
            try XCJSON.Decoder.decode(value: record.json) as Project
        }
    }

    @Test func testFullProjectDecodingPerformance() throws {
        try measureTransformingSampleProjectData { record in
            try XCSchema.Project(jsonRepresentation: record.data)
        }
    }

    @Test func testRawJSONEncodePerformance() throws {
        try measureTransformingSampleProjectData { record in
            record.json.dataRepresentation(options: .defaultOptions)
        }
    }

    @Test func testIsolatedProjectEncodePerformance() throws {
        try measureTransformingSampleProjectData { record in
            try XCJSON.Encoder.value(for: record.project, options: .defaultOptions)
        }
    }

    @Test func testFullProjectEncodePerformance() throws {
        try measureTransformingSampleProjectData { record in
            try XCJSON.Encoder.data(for: record.project, options: .defaultOptions)
        }
    }
}

@Suite struct TestPerformanceTestGating {
    /// `ENABLE_PERFORMANCE_TESTS` is declared on the test target in `Package.swift`.
    /// A manifest change that replaces, rather than extends, a target's `swiftSettings`
    /// silently drops that definition and leaves the performance tests permanently skipped.
    @Test func testGatingMatchesBuildConfiguration() {
        #if DEBUG
        #expect(performanceTestsAreEnabledForBuildConfiguration == false)
        #else
        #expect(performanceTestsAreEnabledForBuildConfiguration == true, "ENABLE_PERFORMANCE_TESTS should be defined for release builds of the test target.")
        #endif
    }
}
