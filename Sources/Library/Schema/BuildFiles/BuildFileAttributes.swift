//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// A subset of the attributes from build file properties, separated to support the encoding schema of folder exception sets.
    ///
    /// Specifically, a subset of ``BuildFileProperties``. Customizes the way a build file behaves in a build phase, for example by limiting to a specific set of platforms, marking headers as public/private, adding custom compiler flags, etc.
    public struct BuildFileAttributes: Equatable, Sendable {
        public enum HeaderPreservation: String, Equatable, XCJSON.StringCodable, Sendable {
            case keep = "keep"
            case removeOnCopy = "remove-on-copy"
        }

        public enum HeaderRole: String, Equatable, XCJSON.StringCodable, Sendable {
            case `public` = "public"
            case `private` = "private"
        }

        public enum MachInterfaceGeneration: String, Equatable, XCJSON.StringCodable, Sendable {
            case `client` = "client"
            case `server` = "server"
            case `both` = "both"
        }

        public enum CodeGenerationVisibility: String, Equatable, XCJSON.StringCodable, Sendable {
            case `public` = "public"
            case `private` = "private"
            case `project` = "project"
        }

        public enum CodeGeneration: String, Equatable, XCJSON.StringCodable, Sendable {
            case `default` = "default"
            case skip = "skip"
        }

        public var headerRole: HeaderRole?
        public var machInterfaceGeneration: MachInterfaceGeneration?
        public var isWeak: Bool
        public var codeSignOnCopy: Bool
        public var codeGeneration: CodeGeneration
        public var headerPreservation: HeaderPreservation
        public var decompress: Bool
        public var codeGenerationVisibility: CodeGenerationVisibility?

        public init(headerRole: HeaderRole?, machInterfaceGeneration: MachInterfaceGeneration?, isWeak: Bool, codeSignOnCopy: Bool, codeGeneration: CodeGeneration, headerPreservation: HeaderPreservation, decompress: Bool, codeGenerationVisibility: CodeGenerationVisibility?) {
            self.headerRole = headerRole
            self.machInterfaceGeneration = machInterfaceGeneration
            self.isWeak = isWeak
            self.codeSignOnCopy = codeSignOnCopy
            self.codeGeneration = codeGeneration
            self.headerPreservation = headerPreservation
            self.decompress = decompress
            self.codeGenerationVisibility = codeGenerationVisibility
        }


        static let defaultInstance = Self(
            headerRole: nil,
            machInterfaceGeneration: nil,
            isWeak: false,
            codeSignOnCopy: false,
            codeGeneration: .default,
            headerPreservation: .keep,
            decompress: false,
            codeGenerationVisibility: nil
        )

        internal var everythingIsDefault: Bool {
            (self == Self.defaultInstance)
        }
    }
}

extension XCSchema.BuildFileAttributes: XCJSON.InlineKeyedCodable {
    package func encode(with container: XCJSON.Encoder.KeyedContainer) throws {
        try container.encode(headerRole, for: "header-role", defaultValue: Self.defaultInstance.headerRole)
        try container.encode(machInterfaceGeneration, for: "mach-interface-generation", defaultValue: Self.defaultInstance.machInterfaceGeneration)
        try container.encode(isWeak, for: "is-weak", defaultValue: Self.defaultInstance.isWeak)
        try container.encode(codeSignOnCopy, for: "code-sign-on-copy", defaultValue: Self.defaultInstance.codeSignOnCopy)
        try container.encode(codeGeneration, for: "code-generation", defaultValue: Self.defaultInstance.codeGeneration)
        try container.encode(headerPreservation, for: "header-preservation", defaultValue: Self.defaultInstance.headerPreservation)
        try container.encode(decompress, for: "decompress", defaultValue: Self.defaultInstance.decompress)
        try container.encode(codeGenerationVisibility, for: "code-generation-visibility", defaultValue: Self.defaultInstance.codeGenerationVisibility)
    }

    package init(with container: XCJSON.Decoder.KeyedContainer) throws {
        headerRole = try container.decode("header-role", defaultValue: Self.defaultInstance.headerRole)
        machInterfaceGeneration = try container.decode("mach-interface-generation", defaultValue: Self.defaultInstance.machInterfaceGeneration)
        isWeak = try container.decode("is-weak", defaultValue: Self.defaultInstance.isWeak)
        codeSignOnCopy = try container.decode("code-sign-on-copy", defaultValue: Self.defaultInstance.codeSignOnCopy)
        codeGeneration = try container.decode("code-generation", defaultValue: Self.defaultInstance.codeGeneration)
        headerPreservation = try container.decode("header-preservation", defaultValue: Self.defaultInstance.headerPreservation)
        decompress = try container.decode("decompress", defaultValue: Self.defaultInstance.decompress)
        codeGenerationVisibility = try container.decode("code-generation-visibility", defaultValue: Self.defaultInstance.codeGenerationVisibility)
    }
}
