//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation
import Testing
import XcodeProjectFormat
import Dispatch
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

struct XcodeProjectToolTests {
    @Test func help() throws {
        let result = try runTool(arguments: ["--help"])

        #expect(result.status == 0)
        #expect(result.stderr.isEmpty)
        #expect(String(decoding: result.stdout, as: UTF8.self).contains("Usage:"))
    }

    @Test func readsStandardInputAndWritesStandardOutput() throws {
        let result = try runTool(arguments: [], input: fixtureData(named: "input"))
        let expected = try fixtureData(named: "expected")

        try expectSuccessful(result)
        #expect(result.stdout == expected)
        try expectProjectCanDecode(result.stdout)
    }

    @Test func readsPositionalOuterProjectPath() throws {
        try withTemporaryDirectory { temporaryDirectory in
            let inputProject = try copyInputProject(to: temporaryDirectory)
            let result = try runTool(arguments: [inputProject.path])
            let expected = try fixtureData(named: "expected")

            try expectSuccessful(result)
            #expect(result.stdout == expected)
            try expectProjectCanDecode(result.stdout)
        }
    }

    @Test func readsInnerInputAndWritesInnerOutput() throws {
        try withTemporaryDirectory { temporaryDirectory in
            let input = temporaryDirectory.appendingPathComponent("input.project.xcproj")
            let output = temporaryDirectory.appendingPathComponent("output.project.xcproj")
            try FileManager.default.copyItem(at: fixtureURL(named: "input"), to: input)

            let result = try runTool(arguments: [
                "--input", input.path,
                "--output", output.path,
            ])

            try expectSuccessfulFileOutput(result, at: output)
        }
    }

    @Test func writesToOuterProjectPath() throws {
        try withTemporaryDirectory { temporaryDirectory in
            let inputProject = try copyInputProject(to: temporaryDirectory)
            let outputProject = temporaryDirectory.appendingPathComponent("Output.xcodeproj")

            let result = try runTool(arguments: [
                "--input", inputProject.path,
                "--output", outputProject.path,
            ])

            try expectSuccessfulFileOutput(result, at: outputProject.appendingPathComponent("project.xcproj"))
        }
    }

    @Test func updatesOuterProjectInPlace() throws {
        try withTemporaryDirectory { temporaryDirectory in
            let project = try copyInputProject(to: temporaryDirectory)
            let result = try runTool(arguments: ["--update", project.path])

            try expectSuccessfulFileOutput(result, at: project.appendingPathComponent("project.xcproj"))
        }
    }

    @Test func failedUpdateLeavesInputUnchanged() throws {
        try withTemporaryDirectory { temporaryDirectory in
            let project = temporaryDirectory.appendingPathComponent("Malformed.xcodeproj")
            let input = project.appendingPathComponent("project.xcproj")
            let original = Data("{\n  \"files\": [\n".utf8)
            try FileManager.default.createDirectory(at: project, withIntermediateDirectories: true)
            try original.write(to: input)

            let result = try runTool(arguments: ["--update", project.path])

            #expect(result.status != 0)
            #expect(result.stdout.isEmpty)
            #expect(!result.stderr.isEmpty)
            let current = try Data(contentsOf: input)
            #expect(current == original)
        }
    }
}

struct ToolTestSupportTests {
    @Test func missingExecutableDoesNotFallBackToOtherBuilds() throws {
        try withTemporaryDirectory { directory in
            let stale = directory.appendingPathComponent("xcprojformatter")
            try FileManager.default.copyItem(atPath: "/bin/echo", toPath: stale.path)
            let products = directory.appendingPathComponent("Debug")
            try FileManager.default.createDirectory(at: products, withIntermediateDirectories: true)
            let testBundle = products.appendingPathComponent("Tests.xctest")
            let resourceBundle = products.appendingPathComponent("Tests.bundle")
            for environment in [
                [:],
                ["BUILT_PRODUCTS_DIR": products.path],
                ["XCPROJFORMATTER_PATH": products.appendingPathComponent("missing").path,
                 "BUILT_PRODUCTS_DIR": directory.path],
            ] {
                #expect(throws: ToolTestError.self) {
                    try formatterURL(environment: environment, testBundle: testBundle, resourceBundle: resourceBundle)
                }
            }
        }
    }

    @Test func capturesOutputLargerThanPipeCapacity() throws {
        let result = try runProcess(
            executable: URL(fileURLWithPath: "/bin/sh"),
            arguments: ["-c", "i=0; while [ $i -lt 10000 ]; do printf 0123456789abcdef; printf fedcba9876543210 >&2; i=$((i+1)); done"]
        )
        #expect(result.status == 0)
        #expect(result.stdout == Data(String(repeating: "0123456789abcdef", count: 10000).utf8))
        #expect(result.stderr == Data(String(repeating: "fedcba9876543210", count: 10000).utf8))
    }

    @Test func timeoutKillsUnresponsiveProcessAndReportsOutput() throws {
        do {
            _ = try runProcess(
                executable: URL(fileURLWithPath: "/bin/sh"),
                arguments: ["-c", "trap '' TERM; echo $$; echo waiting >&2; while :; do :; done"],
                timeout: 1
            )
            Issue.record("Expected the process to time out")
        } catch let ToolTestError.timedOut(command, stdout, stderr) {
            #expect(command.contains("/bin/sh"))
            #expect(String(decoding: stderr, as: UTF8.self).contains("waiting"))
            let pid = try #require(Int32(String(decoding: stdout, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)))
            #expect(kill(pid, 0) == -1)
            #expect(errno == ESRCH)
        }
    }
}

private struct ToolResult {
    var status: Int32
    var stdout: Data
    var stderr: Data
}

private enum ToolTestError: Error, CustomStringConvertible {
    case missingFixture(String)
    case missingExecutable(String)
    case timedOut(String, Data, Data)

    var description: String {
        switch self {
            case let .missingFixture(name): "Missing test fixture \(name)"
            case let .missingExecutable(path): "Missing executable at \(path)"
            case let .timedOut(command, stdout, stderr):
                "Timed out: \(command)\nstdout:\n\(String(decoding: stdout, as: UTF8.self))\nstderr:\n\(String(decoding: stderr, as: UTF8.self))"
        }
    }
}

private func runTool(arguments: [String], input: Data? = nil) throws -> ToolResult {
    try runProcess(executable: formatterURL(), arguments: arguments, input: input)
}

private func runProcess(executable: URL, arguments: [String], input: Data? = nil, timeout: TimeInterval = 30) throws -> ToolResult {
    try withTemporaryDirectory { directory in
        let process = Process()
        process.executableURL = executable
        process.arguments = arguments
        let inputURL = directory.appendingPathComponent("stdin")
        let outputURL = directory.appendingPathComponent("stdout")
        let errorURL = directory.appendingPathComponent("stderr")
        try (input ?? Data()).write(to: inputURL)
        try Data().write(to: outputURL)
        try Data().write(to: errorURL)
        let standardInput = try FileHandle(forReadingFrom: inputURL)
        defer { try? standardInput.close() }
        let standardOutput = try FileHandle(forWritingTo: outputURL)
        defer { try? standardOutput.close() }
        let standardError = try FileHandle(forWritingTo: errorURL)
        defer { try? standardError.close() }
        process.standardInput = standardInput
        process.standardOutput = standardOutput
        process.standardError = standardError
        let exited = DispatchSemaphore(value: 0)
        process.terminationHandler = { _ in exited.signal() }
        try process.run()
        let timedOut = exited.wait(timeout: .now() + timeout) == .timedOut
        if timedOut {
            process.terminate()
            if exited.wait(timeout: .now() + 1) == .timedOut {
                kill(process.processIdentifier, SIGKILL)
                process.waitUntilExit()
            }
        }
        let stdout = try Data(contentsOf: outputURL)
        let stderr = try Data(contentsOf: errorURL)
        if timedOut {
            throw ToolTestError.timedOut(([executable.path] + arguments).joined(separator: " "), stdout, stderr)
        }
        return ToolResult(
            status: process.terminationStatus,
            stdout: stdout,
            stderr: stderr,
        )
    }
}

private final class TestBundleMarker {}

private func formatterURL(
    environment: [String: String] = ProcessInfo.processInfo.environment,
    testBundle: URL = Bundle(for: TestBundleMarker.self).bundleURL,
    resourceBundle: URL = Bundle.module.bundleURL
) throws -> URL {
    let executable: URL
    if let path = environment["XCPROJFORMATTER_PATH"] {
        executable = URL(fileURLWithPath: path)
    } else if let products = environment["BUILT_PRODUCTS_DIR"] {
        executable = URL(fileURLWithPath: products).appendingPathComponent("xcprojformatter")
    } else {
        // XCTest bundles and SwiftPM resource bundles sit beside their build products.
        let bundle = testBundle.pathExtension == "xctest" ? testBundle : resourceBundle
        executable = bundle.deletingLastPathComponent().appendingPathComponent("xcprojformatter")
    }
    guard FileManager.default.isExecutableFile(atPath: executable.path) else {
        throw ToolTestError.missingExecutable(executable.path)
    }
    return executable
}

private func fixtureURL(named name: String) throws -> URL {
    guard let url = Bundle.module.url(forResource: "\(name).project.xcproj", withExtension: nil, subdirectory: "Fixtures") else {
        throw ToolTestError.missingFixture(name)
    }
    return url
}

private func fixtureData(named name: String) throws -> Data {
    try Data(contentsOf: fixtureURL(named: name))
}

private func copyInputProject(to temporaryDirectory: URL) throws -> URL {
    let project = temporaryDirectory.appendingPathComponent("Input.xcodeproj")
    try FileManager.default.createDirectory(at: project, withIntermediateDirectories: true)
    try FileManager.default.copyItem(
        at: fixtureURL(named: "input"),
        to: project.appendingPathComponent("project.xcproj"),
    )
    return project
}

private func expectSuccessful(_ result: ToolResult) throws {
    #expect(result.status == 0)
    #expect(result.stderr.isEmpty)
}

private func expectSuccessfulFileOutput(_ result: ToolResult, at output: URL) throws {
    try expectSuccessful(result)
    let expected = try fixtureData(named: "expected")
    let actual = try Data(contentsOf: output)
    #expect(result.stdout.isEmpty)
    #expect(actual == expected)
    try expectProjectCanDecode(actual)
}

private func expectProjectCanDecode(_ data: Data) throws {
    _ = try XCSchema.Project(jsonRepresentation: data)
}

private func withTemporaryDirectory<Result>(body: (URL) throws -> Result) throws -> Result {
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent("XcodeProjectToolTests-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    return try body(directory)
}
