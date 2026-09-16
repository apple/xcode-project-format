//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import XcodeProjectFormat
import Foundation


struct SampleData : Sendable {
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
        self.records = try paths.map(Record.init(path:))
    }

    init() throws {
        try self.init(sourceDirectory: ProcessInfo.processInfo.environment["XC_PROJECT_FORMAT_TEST_PROJECT_SOURCE_DIR"].unwrap(orThrow: "Missing environment variable for \("XC_PROJECT_FORMAT_TEST_PROJECT_SOURCE_DIR".quoted)"))
    }
}


