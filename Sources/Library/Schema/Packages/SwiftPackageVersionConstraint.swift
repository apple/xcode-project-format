//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// The version constraint on a remote Swift package.
    ///
    /// For example, `.versionRange(min: 1.0, max: 1.5)`.
    public enum SwiftPackageVersionConstraint: Equatable, Sendable {
        case revision(String)
        case branch(String)
        case version(String)
        case versionRange(min: String, max: String)
        case upToNextMinorVersion(String)
        case upToNextMajorVersion(String)

        enum Kind: String, XCJSON.StringCodable {
            case revision = "revision"
            case branch = "branch"
            case version = "version"
            case versionRange = "version-range"
            case upToNextMinorVersion = "up-to-next-minor-version"
            case upToNextMajorVersion = "up-to-next-major-version"
        }

        var kind: Kind {
            switch self {
                case .revision: .revision
                case .branch: .branch
                case .version: .version
                case .versionRange: .versionRange
                case .upToNextMinorVersion: .upToNextMinorVersion
                case .upToNextMajorVersion: .upToNextMajorVersion
            }
        }
    }
}

extension XCSchema.SwiftPackageVersionConstraint: XCJSON.InlineKeyedCodable {
    private static func isBasicVersionNumber(_ string: String) -> Bool {
        string.allSatisfy { character in
            character.isASCII && (character.isNumber || (character == "."))
        }
    }

    package func encode(with container: XCJSON.Encoder.KeyedContainer) throws {
        switch self {
            case let .revision(revision):
                try container.encode(revision, for: "revision", unconditionally: .affirmative)
            case let .branch(branch):
                try container.encode(branch, for: "branch", unconditionally: .affirmative)
            case let .version(version):
                try container.encode(version, for: "version", unconditionally: .affirmative)
            case let .upToNextMinorVersion(version):
                try container.encode(version, for: "up-to-next-minor-version", unconditionally: .affirmative)
            case let .upToNextMajorVersion(version):
                try container.encode(version, for: "up-to-next-major-version", unconditionally: .affirmative)
            case let .versionRange(min: min, max: max):
                if Self.isBasicVersionNumber(min) && Self.isBasicVersionNumber(max) {
                    try container.encode(min + "..<" + max, for: "version-range", unconditionally: .affirmative)
                } else {
                    try container.encode(min, for: "version-range-min", unconditionally: .affirmative)
                    try container.encode(max, for: "version-range-max", unconditionally: .affirmative)
                }
        }
    }

    package init(with container: XCJSON.Decoder.KeyedContainer) throws {
        if let value: String = try container.decodeIfPresent("revision") {
            self = .revision(value)
        } else if let value: String = try container.decodeIfPresent("branch") {
            self = .branch(value)
        } else if let value: String = try container.decodeIfPresent("version") {
            self = .version(value)
        } else if let value: String = try container.decodeIfPresent("up-to-next-minor-version") {
            self = .upToNextMinorVersion(value)
        } else if let value: String = try container.decodeIfPresent("up-to-next-major-version") {
            self = .upToNextMajorVersion(value)
        } else if let value: String = try container.decodeIfPresent("version-range") {
            let (min, max) = try value.partition(atOnly: "..<").unwrap(orThrow: "Unexpected version range value \(value.smartQuoted)")
            self = .versionRange(min: String(min), max: String(max))
        } else {
            self = try .versionRange(
                min: container.decode("version-range-min"),
                max: container.decode("version-range-max")
            )
        }
    }
}

