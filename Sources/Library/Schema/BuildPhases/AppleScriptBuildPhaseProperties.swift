//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// The customizable properties of an AppleScript build phase.
    public struct AppleScriptBuildPhaseProperties: Equatable, Sendable {
        public var baseProperties: BuildPhaseProperties
        public var isSharedContext: Bool
        public var contextName: String

        public init(objectID: ObjectID?, name: String?, isSharedContext: Bool, contextName: String) {
            self.baseProperties = BuildPhaseProperties(objectID: objectID, name: name)
            self.isSharedContext = isSharedContext
            self.contextName = contextName
        }
    }
}

extension XCSchema.AppleScriptBuildPhaseProperties: XCJSON.InlineKeyedCodable {
    package func encode(with container: XCJSON.Encoder.KeyedContainer) throws {
        try container.encode(inline: baseProperties)
        try container.encode(isSharedContext, for: "is-shared-context", defaultValue: false)
        try container.encode(contextName, for: "context-name", defaultValue: "")
    }

    package init(with container: XCJSON.Decoder.KeyedContainer) throws {
        baseProperties = try container.decodeInline()
        isSharedContext = try container.decode("is-shared-context", defaultValue: false)
        contextName = try container.decode("context-name", defaultValue: "")
    }

    var printingDensity: XCJSON.PrintingDensity? {
        nil
    }
}
