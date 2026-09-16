//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// A build rule defines a custom action for files in build phases to match against.
    ///
    /// You might create a build rule to recompress images as your application builds.
    public struct BuildRule:  Equatable, CopyWith, Sendable {
        public var processor: String
        public var name: String?
        public var fileType: FileTypeID?
        public var filePatterns: String?
        public var script: String?
        public var inputFiles: [String]
        public var inputFileLists: [String]
        public var outputFiles: [String]
        public var outputFileLists: [String]
        public var outputFilesCompilerFlags: [String]
        public var dependencyFile: String?
        public var runOncePerArchitecture: Bool
        public var objectID: ObjectID?

        public init(objectID: ObjectID?, processor: String, name: String?, fileType: FileTypeID?, filePatterns: String?, script: String?, inputFiles: [String], inputFileLists: [String], outputFiles: [String], outputFileLists: [String], outputFilesCompilerFlags: [String], dependencyFile: String?, runOncePerArchitecture: Bool) {
            self.objectID = objectID
            self.processor = processor
            self.name = name
            self.fileType = fileType
            self.filePatterns = filePatterns
            self.script = script
            self.inputFiles = inputFiles
            self.inputFileLists = inputFileLists
            self.outputFiles = outputFiles
            self.outputFileLists = outputFileLists
            self.outputFilesCompilerFlags = outputFilesCompilerFlags
            self.dependencyFile = dependencyFile
            self.runOncePerArchitecture = runOncePerArchitecture
        }
    }
}

extension XCSchema.BuildRule: XCJSON.Codable {
    package func encode(with coder: XCJSON.Encoder) throws {
        let container = coder.openKeyedContainer()
        try container.encode(name, for: "name", defaultValue: nil)
        try container.encode(objectID, for: "id", defaultValue: nil)
        try container.encode(processor, for: "processor", unconditionally: .affirmative)
        try container.encode(fileType, for: "file-type", defaultValue: nil)
        try container.encode(filePatterns, for: "file-patterns", defaultValue: nil)
        try container.encode(inputFiles, for: "input-files", defaultValue: [])
        try container.encode(inputFileLists, for: "input-file-lists", defaultValue: [])
        try container.encode(outputFiles, for: "output-files", defaultValue: [])
        try container.encode(outputFileLists, for: "output-file-lists", defaultValue: [])
        try container.encode(outputFilesCompilerFlags, for: "output-files-compiler-flags", defaultValue: [])
        try container.encode(dependencyFile, for: "dependency-file", defaultValue: nil)
        try container.encode(runOncePerArchitecture, for: "run-once-per-architecture", defaultValue: true)
        try container.encode(script.map(XCSchema.MultilineText.init), for: "script", defaultValue: nil)
    }

    package init(with coder: XCJSON.Decoder) throws {
        let container = try coder.openKeyedContainer()
        name = try container.decodeIfPresent("name")
        objectID = try container.decode("id", defaultValue: nil)
        processor = try container.decode("processor")
        fileType = try container.decode("file-type", defaultValue: nil)
        filePatterns = try container.decode("file-patterns", defaultValue: nil)
        inputFiles = try container.decode("input-files", defaultValue: [])
        inputFileLists = try container.decode("input-file-lists", defaultValue: [])
        outputFiles = try container.decode("output-files", defaultValue: [])
        outputFileLists = try container.decode("output-file-lists", defaultValue: [])
        outputFilesCompilerFlags = try container.decode("output-files-compiler-flags", defaultValue: [])
        dependencyFile = try container.decode("dependency-file", defaultValue: nil)
        runOncePerArchitecture = try container.decode("run-once-per-architecture", defaultValue: true)
        let multilineScript: XCSchema.MultilineText? = try container.decodeIfPresent("script")
        script = multilineScript?.text
    }
}
