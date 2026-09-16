//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation


extension XCSchema {
    /// Specializes mapping of files nested in a folder to the folder's default targets, either by excluding them, or including them with specialized attributes.
    public struct TargetExceptionSet: Equatable, Sendable {
        public var target: XCSchema.LocalTargetReference

        public var publicHeaders: Set<FolderMemberID>
        public var privateHeaders: Set<FolderMemberID>

        public var additionalCompilerFlags: [FolderMemberID : String]

        public var commonProperties: CommonExceptionSetProperties

        public init(target: XCSchema.LocalTargetReference, publicHeaders: Set<FolderMemberID>, privateHeaders: Set<FolderMemberID>, additionalCompilerFlags: [FolderMemberID : String], commonProperties: CommonExceptionSetProperties) {
            self.target = target
            self.publicHeaders = publicHeaders
            self.privateHeaders = privateHeaders
            self.additionalCompilerFlags = additionalCompilerFlags
            self.commonProperties = commonProperties
        }
    }
}

extension XCSchema.TargetExceptionSet: XCJSON.InlineKeyedCodable {
    package func encode(with container: XCJSON.Encoder.KeyedContainer) throws {
        try container.encode(target, for: "target", unconditionally: .affirmative)
        try container.encode(publicHeaders, for: "public-headers", defaultValue: [])
        try container.encode(privateHeaders, for: "private-headers", defaultValue: [])
        try container.encode(additionalCompilerFlags, for: "compiler-flags", defaultValue: [:])
        try commonProperties.encode(with: container)
    }

    package init(with container: XCJSON.Decoder.KeyedContainer) throws {
        target = try container.decode("target")
        publicHeaders = try container.decode("public-headers", defaultValue: [])
        privateHeaders = try container.decode("private-headers", defaultValue: [])
        additionalCompilerFlags = try container.decode("compiler-flags", defaultValue: [:])
        commonProperties = try .init(with: container)
    }
}
