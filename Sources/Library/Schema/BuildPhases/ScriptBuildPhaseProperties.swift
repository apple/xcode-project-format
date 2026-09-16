//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// Additional properties for script phases that describe the script, its inputs and outputs, and when to run it.
    public struct ScriptBuildPhaseProperties: Equatable, Sendable, CopyWith {
        public var baseProperties: BuildPhaseProperties
        public var shellPath: String
        public var script: String
        public var logEnvironmentVariables: Bool
        public var inputPaths: [String]
        public var inputFileListPaths: [String]
        public var outputPaths: [String]
        public var outputFileListPaths: [String]
        public var dependencyFile: String?
        public var runOnEveryBuild: Bool
        public var scope: BuildPhaseScope

        public init(objectID: ObjectID?, name: String, shellPath: String, script: String, logEnvironmentVariables: Bool, inputPaths: [String], inputFileListPaths: [String], outputPaths: [String], outputFileListPaths: [String], dependencyFile: String?, runOnEveryBuild: Bool, scope: BuildPhaseScope) {
            self.baseProperties = BuildPhaseProperties(objectID: objectID, name: name)
            self.shellPath = shellPath
            self.script = script
            self.logEnvironmentVariables = logEnvironmentVariables
            self.inputPaths = inputPaths
            self.inputFileListPaths = inputFileListPaths
            self.outputPaths = outputPaths
            self.outputFileListPaths = outputFileListPaths
            self.dependencyFile = dependencyFile
            self.runOnEveryBuild = runOnEveryBuild
            self.scope = scope
        }
    }
}


extension XCSchema.ScriptBuildPhaseProperties: XCJSON.InlineKeyedCodable {
    package func encode(with container: XCJSON.Encoder.KeyedContainer) throws {
        try container.encode(inline: baseProperties)
        try container.encode(logEnvironmentVariables, for: "log-environment-variables", defaultValue: false)
        try container.encode(inputPaths, for: "input-paths", defaultValue: [])
        try container.encode(inputFileListPaths, for: "input-file-list-paths", defaultValue: [])
        try container.encode(outputPaths, for: "output-paths", defaultValue: [])
        try container.encode(outputFileListPaths, for: "output-file-list-paths", defaultValue: [])
        try container.encode(dependencyFile, for: "dependency-file", defaultValue: nil)
        try container.encode(runOnEveryBuild, for: "run-on-every-build", defaultValue: false)
        try container.encode(scope, for: "scope", defaultValue: .always)
        try container.encode(shellPath, for: "shell", unconditionally: .affirmative)
        try container.encode(XCSchema.MultilineText(text: script), for: "script", unconditionally: .affirmative)
    }

    package init(with container: XCJSON.Decoder.KeyedContainer) throws {
        baseProperties = try container.decodeInline()
        logEnvironmentVariables = try container.decode("log-environment-variables", defaultValue: false)
        inputPaths = try container.decode("input-paths", defaultValue: [])
        inputFileListPaths = try container.decode("input-file-list-paths", defaultValue: [])
        outputPaths = try container.decode("output-paths", defaultValue: [])
        outputFileListPaths = try container.decode("output-file-list-paths", defaultValue: [])
        dependencyFile = try container.decode("dependency-file", defaultValue: nil)
        runOnEveryBuild = try container.decode("run-on-every-build", defaultValue: false)
        scope = try container.decode("scope", defaultValue: .always)
        shellPath = try container.decode("shell")
        let multilineScript: XCSchema.MultilineText = try container.decode("script")
        script = multilineScript.text
    }

    var printingDensity: XCJSON.PrintingDensity? {
        nil
    }
}
