//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0 with Runtime Library Exception
// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
//
//===----------------------------------------------------------------------===//

#if os(macOS) || os(Linux) || os(Windows)

import Foundation
import Testing
import XcodeProjectFormat

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

private struct ToolResult {
    var status: Int32
    var stdout: Data
    var stderr: Data
}

private enum ToolTestError: Error, CustomStringConvertible {
    case missingFixture(String)
    case unexpectedBinaryCandidates([String])

    var description: String {
        switch self {
            case let .missingFixture(name): "Missing test fixture \(name)"
            case let .unexpectedBinaryCandidates(candidates):
                "Expected one matching xcprojformatter binary, found: \(candidates.joined(separator: ", "))"
        }
    }
}

private func runTool(arguments: [String], input: Data? = nil, sourceFilePath: String = #filePath) throws -> ToolResult {
    let process = Process()
    process.executableURL = try formatterURL(sourceFilePath: sourceFilePath)
    process.arguments = arguments

    let standardInput = Pipe()
    let standardOutput = Pipe()
    let standardError = Pipe()
    process.standardInput = standardInput
    process.standardOutput = standardOutput
    process.standardError = standardError

    try process.run()
    if let input {
        try standardInput.fileHandleForWriting.write(contentsOf: input)
    }
    try standardInput.fileHandleForWriting.close()
    process.waitUntilExit()

    return ToolResult(
        status: process.terminationStatus,
        stdout: standardOutput.fileHandleForReading.readDataToEndOfFile(),
        stderr: standardError.fileHandleForReading.readDataToEndOfFile(),
    )
}

private func formatterURL(sourceFilePath: String) throws -> URL {
    let packageRoot = URL(fileURLWithPath: sourceFilePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
    let buildDirectory = packageRoot.appendingPathComponent(".build")
    let fileManager = FileManager.default
    #if DEBUG
    let buildConfiguration = "Debug"
    #else
    let buildConfiguration = "Release"
    #endif
    let candidates = (fileManager.enumerator(
        at: buildDirectory,
        includingPropertiesForKeys: [.isRegularFileKey, .isExecutableKey],
        options: [],
    )?.compactMap { $0 as? URL } ?? []).filter { url in
        (url.lastPathComponent == "xcprojformatter" || url.lastPathComponent == "xcprojformatter.exe")
            && url.pathComponents.contains(buildConfiguration)
            && fileManager.isExecutableFile(atPath: url.path)
    }

    guard candidates.count == 1 else {
        throw ToolTestError.unexpectedBinaryCandidates(candidates.map(\.path).sorted())
    }
    return candidates[0]
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

#endif
