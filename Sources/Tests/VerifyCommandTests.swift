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

struct VerifyCommandTests {
    private struct ProcessResult {
        let terminationStatus: Int32
        let stdout: Data
        let stderr: Data
    }

    private func executableURL() throws -> URL {
        #if os(Windows)
        let binaryName = "xcprojformatter.exe"
        #else
        let binaryName = "xcprojformatter"
        #endif

        var candidateDirectories: [URL] = []
        if let builtProductsDir = ProcessInfo.processInfo.environment["BUILT_PRODUCTS_DIR"] {
            candidateDirectories.append(URL(fileURLWithPath: builtProductsDir))
        }
        for bundle in Bundle.allBundles where bundle.bundleURL.pathExtension == "xctest" {
            candidateDirectories.append(bundle.bundleURL.deletingLastPathComponent())
        }
        for argument in CommandLine.arguments {
            var url = URL(fileURLWithPath: argument)
            while url.path != "/" && !url.lastPathComponent.hasSuffix(".xctest") {
                url.deleteLastPathComponent()
            }
            if url.lastPathComponent.hasSuffix(".xctest") {
                candidateDirectories.append(url.deletingLastPathComponent())
            }
        }

        for directory in candidateDirectories {
            let candidate = directory.appendingPathComponent(binaryName)
            if FileManager.default.isExecutableFile(atPath: candidate.path) {
                return candidate
            }
        }

        Issue.record("Could not locate \(binaryName) executable in \(candidateDirectories.map(\.path))")
        throw CancellationError()
    }

    private func runFormatter(_ arguments: [String], stdin: Data? = nil) throws -> ProcessResult {
        let process = Process()
        process.executableURL = try executableURL()
        process.arguments = arguments

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        let stdinPipe = Pipe()
        process.standardInput = stdinPipe

        try process.run()
        if let stdin {
            try stdinPipe.fileHandleForWriting.write(contentsOf: stdin)
        }
        try stdinPipe.fileHandleForWriting.close()
        process.waitUntilExit()

        let stdout = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stderr = stderrPipe.fileHandleForReading.readDataToEndOfFile()
        return ProcessResult(terminationStatus: process.terminationStatus, stdout: stdout, stderr: stderr)
    }

    private func canonicalProjectData() throws -> Data {
        let minimal = Data(#"{"default-configuration":"Debug","localizations":{"development":"en"},"files":[]}"#.utf8)
        return try XCSchema.Project(jsonRepresentation: minimal).jsonRepresentation()
    }

    private func withTemporaryDirectory(_ body: (URL) throws -> ()) throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("VerifyCommandTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        try body(dir)
    }

    @Test func canonicalInputExitsZeroWithEmptyStdoutAndUnchangedFile() throws {
        let canonical = try canonicalProjectData()

        try withTemporaryDirectory { dir in
            let projectDir = dir.appendingPathComponent("Sample.xcodeproj")
            try FileManager.default.createDirectory(at: projectDir, withIntermediateDirectories: true)
            let projectFile = projectDir.appendingPathComponent("project.xcproj")
            try canonical.write(to: projectFile)

            for args in [
                ["--verify", "--input", projectDir.path],
                ["--verify", projectFile.path],
            ] {
                let result = try runFormatter(args)
                #expect(result.terminationStatus == 0)
                #expect(result.stdout.isEmpty)
                #expect(try Data(contentsOf: projectFile) == canonical)
            }

            let stdinResult = try runFormatter(["--verify"], stdin: canonical)
            #expect(stdinResult.terminationStatus == 0)
            #expect(stdinResult.stdout.isEmpty)
        }
    }

    @Test func nonCanonicalInputWithExtraNewlineExitsOneWithEmptyStdoutAndUnchangedFile() throws {
        let nonCanonical = try canonicalProjectData() + Data("\n".utf8)

        try withTemporaryDirectory { dir in
            let projectFile = dir.appendingPathComponent("project.xcproj")
            try nonCanonical.write(to: projectFile)

            let result = try runFormatter(["--verify", "--input", projectFile.path])
            #expect(result.terminationStatus == 1)
            #expect(result.stdout.isEmpty)
            #expect(try Data(contentsOf: projectFile) == nonCanonical)

            let stdinResult = try runFormatter(["--verify"], stdin: nonCanonical)
            #expect(stdinResult.terminationStatus == 1)
            #expect(stdinResult.stdout.isEmpty)
        }
    }

    @Test func malformedInputExitsNonzeroWithDiagnostic() throws {
        try withTemporaryDirectory { dir in
            let projectFile = dir.appendingPathComponent("project.xcproj")
            try Data("{invalid json".utf8).write(to: projectFile)

            let result = try runFormatter(["--verify", "--input", projectFile.path])
            #expect(result.terminationStatus != 0)
            #expect(!result.stderr.isEmpty)
        }
    }

    @Test func missingInputFileExitsNonzeroWithDiagnostic() throws {
        try withTemporaryDirectory { dir in
            let missingFile = dir.appendingPathComponent("missing.xcproj")
            let result = try runFormatter(["--verify", "--input", missingFile.path])
            #expect(result.terminationStatus != 0)
            #expect(!result.stderr.isEmpty)
        }
    }

    @Test func conflictingOutputOptionsFailWithoutCreatingOrModifyingFiles() throws {
        let nonCanonical = try canonicalProjectData() + Data("\n".utf8)

        try withTemporaryDirectory { dir in
            let inputFile = dir.appendingPathComponent("input.xcproj")
            let outputFile = dir.appendingPathComponent("output.xcproj")
            try nonCanonical.write(to: inputFile)

            let invocations = [
                ["--verify", "--input", inputFile.path, "--output", outputFile.path],
                ["--output", outputFile.path, "--input", inputFile.path, "--verify"],
                ["--verify", "--update", inputFile.path],
                ["--update", inputFile.path, "--verify"],
            ]

            for args in invocations {
                let result = try runFormatter(args)
                #expect(result.terminationStatus != 0)
                #expect(!result.stderr.isEmpty)
                #expect(!FileManager.default.fileExists(atPath: outputFile.path))
                #expect(try Data(contentsOf: inputFile) == nonCanonical)
            }
        }
    }
}

#endif
