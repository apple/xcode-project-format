//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import XcodeProjectFormat
import Foundation

platform_exit(main())

func main() -> Int32 {
    do {
        let arguments = try Arguments(commandLine: CommandLine.arguments)
        if arguments.help {
            try printHelp(to: .standardOutput)
        } else {
            let inputData = try readInputData(from: arguments.inputPath)
            let outputData = try prettyPrint(input: inputData)
            try writeOutput(data: outputData, to: arguments.outputPath)
        }
        return 0
    } catch {
        let error = error as NSError
        let message = error.localizedDescriptionCombinedWithRecoverySuggestionIfPresent + "\n\n----------------------------\n\n"
        try! FileHandle.standardError.write(contentsOf: message.utf8.asData)
        try! printHelp(to: .standardError)
        return -1
    }
}

func addingFileComponentIfNeeded(_ path: String) -> String {
    path.pathExtension == "xcodeproj" ? path.appendingPathComponent("project.xcproj") : path
}

func writeOutput(data: Data, to outputPath: String?) throws {
    if let outputPath {
        if outputPath.pathExtension == "xcodeproj" {
            try FileManager.default.createDirectory(atPath: outputPath, withIntermediateDirectories: false, ignoringFileExistsErrors: true)
        }
        do {
            try (data as NSData).write(toFile: addingFileComponentIfNeeded(outputPath))
        } catch {
            if error.isNoSuchFile {
                throw NSError("Could not write to output file \(outputPath.quoted)")
            } else {
                throw error
            }
        }
    } else {
        return try FileHandle.standardOutput.write(contentsOf: data)
    }
}

func readInputData(from inputPath: String?) throws -> Data {
    if let inputPath {
        let inputPath = addingFileComponentIfNeeded(inputPath)
        let handle = try FileHandle(forReadingAtPath: inputPath).unwrap(orThrow: "Could not open \(inputPath.quoted) for reading")
        let inputData = try handle.readToEnd().unwrap(orThrow: "Could not read \(inputPath.quoted)")
        try handle.close()
        return inputData
    } else {
        return try FileHandle.standardInput.readToEnd().unwrap(orThrow: "Could not read standard input")
    }
}

func printHelp(to handle: FileHandle) throws {
    try handle.write(contentsOf: helpText().utf8.asData)
}

func prettyPrint(input: Data) throws -> Data {
    try Project(jsonRepresentation: input).jsonRepresentation()
}
