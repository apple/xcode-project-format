//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// Specifies the development and supported languages for a project.
    public struct ProjectLocalizationInfo: Equatable, Sendable {
        public var development: Language
        public var supported: Set<Language> // Should not include the development language

        public init(development: Language, supported: Set<Language>) {
            precondition(!supported.contains(development))
            self.development = development
            self.supported = supported
        }

        public var allLanguages: Set<Language> {
            supported.union([development])
        }
    }
}

extension XCSchema.ProjectLocalizationInfo: XCJSON.Codable {
    package func encode(with coder: XCJSON.Encoder) throws {
        let container = coder.openKeyedContainer()
        try container.encode(development, for: "development", unconditionally: .affirmative)
        try container.encode(supported, for: "supported", defaultValue: [])
    }

    package init(with coder: XCJSON.Decoder) throws {
        let container = try coder.openKeyedContainer()
        development = try container.decode("development")
        supported = try container.decode("supported", defaultValue: [])
    }
}

