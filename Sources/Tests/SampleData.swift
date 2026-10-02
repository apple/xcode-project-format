//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0 with Runtime Library Exception
// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
//
//===----------------------------------------------------------------------===//

import XcodeProjectFormat
import Foundation


struct SampleData : Sendable {
    static let sourceDirectoryEnvironmentVariable = "XC_PROJECT_FORMAT_TEST_PROJECT_SOURCE_DIR"

    static var sourceDirectory: String? {
        ProcessInfo.processInfo.environment[sourceDirectoryEnvironmentVariable]
    }

    static let sharedInstance = Result {
        try SampleData()
    }

    struct Record: Sendable {
        var path: String
        var data: Data
        var json: XCJSON.Value
        var project: XCSchema.Project

        init(path: String) throws {
            self.path = path
            self.data = try Data(contentsOf: path)
            self.json = try XCJSON.Value(data: data)
            self.project = try XCJSON.Decoder.decode(value: json)
        }
    }

    let records: [Record]
    init(sourceDirectory: String) throws {
        let paths = try FileManager.default.recursivelyFindFiles(matchingExtension: "xcproj", in: sourceDirectory)
        guard !paths.isEmpty else {
            throw NSError("No .xcproj files found in \(sourceDirectory.quoted)")
        }
        self.records = try paths.map(Record.init(path:))
    }

    init() throws {
        try self.init(sourceDirectory: Self.sourceDirectory.unwrap(orThrow: "Missing environment variable for \(Self.sourceDirectoryEnvironmentVariable.quoted)"))
    }
}


