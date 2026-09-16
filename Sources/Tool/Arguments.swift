//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation
import XcodeProjectFormat

struct Arguments {
    var inputPath: String?
    var outputPath: String?
    var help = false

    init(commandLine: [String]) throws {
        var remaining = commandLine.dropFirst()
        while let next = remaining.extractFirst() {
            switch next {
                case "--help":
                    help = true
                case "--input":
                    try require(inputPath == nil, orThrow: "Two values passed for '--input'")
                    inputPath = try remaining.extractFirst().unwrap(orThrow: "Missing argument for '--input'")
                case "--output":
                    try require(outputPath == nil, orThrow: "Two values passed for '--output'")
                    outputPath = try remaining.extractFirst().unwrap(orThrow: "Missing argument for '--output'")
                case "--update":
                    try require(outputPath == nil, orThrow: "Two values passed for output")
                    try require(inputPath == nil, orThrow: "Two values passed for input")
                    let path = try remaining.extractFirst().unwrap(orThrow: "Missing argument for '--update'")
                    inputPath = path
                    outputPath = path
                default:
                    if (inputPath == nil), !next.hasPrefix("--") {
                        inputPath = next
                    } else {
                        throw NSError("Unexpected argument: \(next.quoted)")
                    }
            }
        }
        inputPath = inputPath?.expandingTildeInPath
        outputPath = outputPath?.expandingTildeInPath
    }
}
