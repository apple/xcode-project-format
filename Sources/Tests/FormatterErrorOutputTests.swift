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

struct FormatterErrorOutputTests {
    private struct ProcessResult {
        let terminationStatus: Int32
        let stdout: String
        let stderr: String
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

        let stdout = String(decoding: stdoutPipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        let stderr = String(decoding: stderrPipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        return ProcessResult(terminationStatus: process.terminationStatus, stdout: stdout, stderr: stderr)
    }

    private func withTemporaryDirectory(_ body: (URL) throws -> ()) throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("FormatterErrorOutputTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        try body(dir)
    }

    @Test func decodeFailurePrintsDiagnosticWithoutHelpText() throws {
        let projectMissingTargetName = Data(#"{"default-configuration":"Debug","files":[],"localizations":{"development":"en"},"targets":[{}]}"#.utf8)

        try withTemporaryDirectory { dir in
            let projectFile = dir.appendingPathComponent("project.xcproj")
            try projectMissingTargetName.write(to: projectFile)

            let result = try runFormatter(["--input", projectFile.path])
            #expect(result.terminationStatus == 1)
            #expect(result.stdout.isEmpty)
            #expect(result.stderr.contains("Missing required value for key “name” at “/targets[0]”"))
            #expect(!result.stderr.contains("Usage:"))
            #expect(!result.stderr.contains("----------------------------"))
        }
    }

    @Test func malformedJSONPrintsDiagnosticWithoutHelpText() throws {
        let result = try runFormatter([], stdin: Data("{invalid".utf8))
        #expect(result.terminationStatus == 1)
        #expect(result.stdout.isEmpty)
        #expect(!result.stderr.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        #expect(!result.stderr.contains("Usage:"))
    }

    @Test func unreadableInputPrintsDiagnosticWithoutHelpText() throws {
        try withTemporaryDirectory { dir in
            let missingFile = dir.appendingPathComponent("missing.xcproj")
            let result = try runFormatter(["--input", missingFile.path])
            #expect(result.terminationStatus == 1)
            #expect(result.stdout.isEmpty)
            #expect(result.stderr.contains("Could not open"))
            #expect(!result.stderr.contains("Usage:"))
        }
    }

    @Test func invalidArgumentsStillPrintHelpText() throws {
        let result = try runFormatter(["--unknown-flag"])
        #expect(result.terminationStatus == 1)
        #expect(result.stdout.isEmpty)
        #expect(result.stderr.contains("Unexpected argument"))
        #expect(result.stderr.contains("Usage:"))
    }
}

#endif
