//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation

extension XCSchema {
    /// A build phase, which exists within a target, and specifies how files should be built.
    public enum BuildPhase: Equatable, Sendable {
        case frameworks(BuildPhaseProperties)
        case headers(BuildPhaseProperties)
        case javaArchive(BuildPhaseProperties)
        case resources(BuildPhaseProperties)
        case rez(BuildPhaseProperties)
        case sources(BuildPhaseProperties)

        case appleScript(AppleScriptBuildPhaseProperties)
        case copy(CopyFilesBuildPhaseProperties)
        case script(ScriptBuildPhaseProperties)

        public enum Kind: String, XCJSON.StringCodable, Equatable, Sendable, CaseIterable {
            case appleScript = "apple-script"
            case frameworks = "frameworks"
            case headers = "headers"
            case javaArchive = "java-archive"
            case resources = "resources"
            case rez = "rez"
            case sources = "compile-sources"
            case copy = "copy"
            case script = "script"

            private static let kindsByRawValue: [String: Self] = {
                var table: [String: Self] = Dictionary()
                table.reserveCapacity(allCases.count)
                for celf in allCases {
                    table[celf.rawValue] = celf
                }
                return table
            }()

            public init?(rawValue: String) {
                if let match = Self.kindsByRawValue[rawValue] {
                    self = match
                } else {
                    return nil
                }
            }

            var errorMessageName: String {
                switch self {
                    case .appleScript: "Apple Script"
                    case .frameworks: "Link Libraries & Frameworks"
                    case .headers: "Copy Headers"
                    case .javaArchive: "Java Archive"
                    case .resources: "Copy Resources"
                    case .rez: "Rez"
                    case .sources: "Compile Sources"
                    case .copy: "Copy Files"
                    case .script: "Shell Script"
                }
            }

            public var encodableStringRepresentation: String {
                rawValue
            }
        }

        public var kind: Kind {
            switch self {
                case .appleScript: .appleScript
                case .frameworks: .frameworks
                case .headers: .headers
                case .javaArchive: .javaArchive
                case .resources: .resources
                case .rez: .rez
                case .sources: .sources
                case .copy: .copy
                case .script: .script
            }
        }

        var name: String? {
            switch self {
                case let .frameworks(properties),
                     let .headers(properties),
                     let .javaArchive(properties),
                     let .resources(properties),
                     let .rez(properties),
                     let .sources(properties): properties.name

                case let .appleScript(properties): properties.baseProperties.name
                case let .copy(properties): properties.baseProperties.name
                case let .script(properties): properties.baseProperties.name
            }
        }

        var encodeAsKindOnly: Bool {
            switch self {
                case let .frameworks(properties),
                     let .headers(properties),
                     let .javaArchive(properties),
                     let .resources(properties),
                     let .rez(properties),
                     let .sources(properties): properties.everythingIsDefault
                case .appleScript, .copy, .script: false
            }
        }
    }
}

extension XCSchema.BuildPhase: XCJSON.Codable {
    package func encode(with coder: XCJSON.Encoder) throws {
        if encodeAsKindOnly {
            coder.encodePrimitive(kind.encodableStringRepresentation)
        } else {
            let container = coder.openKeyedContainer(density: printingDensity)
            try container.encode(kind, for: "kind", unconditionally: .affirmative)

            switch self {
                case let .appleScript(properties): try container.encode(inline: properties)
                case let .frameworks(properties): try container.encode(inline: properties)
                case let .headers(properties): try container.encode(inline: properties)
                case let .javaArchive(properties): try container.encode(inline: properties)
                case let .resources(properties): try container.encode(inline: properties)
                case let .rez(properties): try container.encode(inline: properties)
                case let .sources(properties): try container.encode(inline: properties)
                case let .copy(properties): try container.encode(inline: properties)
                case let .script(properties): try container.encode(inline: properties)
            }
        }
    }

    package init(with coder: XCJSON.Decoder) throws {
        if coder.currentNodeType == .string {
            let kind = try Kind(encodableStringRepresentation: coder.decodePrimitive())
            switch kind {
                case .frameworks: self = .frameworks(.defaultInstance)
                case .headers: self = .headers(.defaultInstance)
                case .javaArchive: self = .javaArchive(.defaultInstance)
                case .resources: self = .resources(.defaultInstance)
                case .rez: self = .rez(.defaultInstance)
                case .sources: self = .sources(.defaultInstance)
                case .appleScript, .copy, .script:
                    throw NSError("Invalid build phase encoding \(kind.encodableStringRepresentation.smartQuoted). The accompanying build phase properties are missing.")
            }
        } else {
            let container = try coder.openKeyedContainer()
            let kind: Kind = try container.decode("kind")
            switch kind {
                case .appleScript: self = try .appleScript(container.decodeInline())
                case .frameworks: self = try .frameworks(container.decodeInline())
                case .headers: self = try .headers(container.decodeInline())
                case .javaArchive: self = try .javaArchive(container.decodeInline())
                case .resources: self = try .resources(container.decodeInline())
                case .rez: self = try .rez(container.decodeInline())
                case .sources: self = try .sources(container.decodeInline())
                case .copy: self = try .copy(container.decodeInline())
                case .script: self = try .script(container.decodeInline())
            }
        }
    }

    var printingDensity: XCJSON.PrintingDensity? {
        switch self {
            case let .appleScript(content): content.printingDensity
            case let .frameworks(content): content.printingDensity
            case let .headers(content): content.printingDensity
            case let .javaArchive(content): content.printingDensity
            case let .resources(content): content.printingDensity
            case let .rez(content): content.printingDensity
            case let .sources(content): content.printingDensity
            case let .copy(content): content.printingDensity
            case let .script(content): content.printingDensity
        }
    }
}

