//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// Additional properties for copy phases that describe where to copy the build files.
    public struct CopyFilesBuildPhaseProperties: Equatable, Sendable {
        public var baseProperties: BuildPhaseProperties
        public var bundleBasePath: BundleBasePath?
        public var relativePath: String // Relative to base
        public var scope: BuildPhaseScope

        public init(objectID: ObjectID?, name: String?, bundleBasePath: BundleBasePath?, relativePath: String, scope: XCSchema.BuildPhaseScope) {
            self.baseProperties = BuildPhaseProperties(objectID: objectID, name: name)
            self.relativePath = relativePath
            self.bundleBasePath = bundleBasePath
            self.scope = scope
        }
    }
}

extension XCSchema.CopyFilesBuildPhaseProperties: XCJSON.InlineKeyedCodable {
    package func encode(with container: XCJSON.Encoder.KeyedContainer) throws {
        try container.encode(inline: baseProperties)
        try container.encode(bundleBasePath, for: "bundle-base-path", defaultValue: nil)
        try container.encode(relativePath, for: "relative-path", defaultValue: "")
        try container.encode(scope, for: "scope", defaultValue: .always)
    }

    package init(with container: XCJSON.Decoder.KeyedContainer) throws {
        baseProperties = try container.decodeInline()
        bundleBasePath = try container.decode("bundle-base-path", defaultValue: nil)
        relativePath = try container.decode("relative-path", defaultValue: "")
        scope = try container.decode("scope", defaultValue: .always)
    }

    var printingDensity: XCJSON.PrintingDensity? {
        nil
    }
}
