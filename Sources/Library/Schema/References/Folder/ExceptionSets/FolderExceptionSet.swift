//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation


extension XCSchema {
    /// A union type representing either kind of folder exception set for altering the mapping of discovered folder content into targets.
    ///
    /// Specifically, content discovered by a ``Folder`` reference. Folders are target members, and discover their nested files dynamically after a project loads. They map their files into targets using the default rules for file types to build phases. Exception sets are used to describe any differences from these default mappings. Most commonly they're used to exclude files from the folder's target. They can also add files to additional targets, specific build phases, or customize things like header roles to make a header public.
    public enum FolderExceptionSet: Equatable, Sendable {
        enum Kind: Equatable {
            case target
            case buildPhase
        }

        var kind: Kind {
            switch self {
                case .target: .target
                case .buildPhase: .buildPhase
            }
        }

        case target(TargetExceptionSet)
        case buildPhase(BuildPhaseExceptionSet)
    }

    /// Signals whether an exception set is an inclusion, or an exclusion.
    ///
    /// Only applies to target exceptions; build phase exceptions are always inclusions.
    public enum ExceptionSetSense: Equatable, CaseIterable, Sendable {
        case inclusions
        case exclusions
        var key: String {
            switch self {
                case .inclusions: "inclusions"
                case .exclusions: "exclusions"
            }
        }
    }
}

extension XCSchema.FolderExceptionSet: XCJSON.Codable {
    package func encode(with coder: XCJSON.Encoder) throws {
        let container = coder.openKeyedContainer()
        switch self {
            case .target(let content): try content.encode(with: container)
            case .buildPhase(let content): try content.encode(with: container)
        }
    }

    package init(with coder: XCJSON.Decoder) throws {
        let container = try coder.openKeyedContainer()
        if container.contains("target") {
            self = try .target(XCSchema.TargetExceptionSet(with: container))
        } else if container.contains("build-phase") {
            self = try .buildPhase(XCSchema.BuildPhaseExceptionSet(with: container))
        } else {
            throw NSError("Unknown exception set. Expected either a target, or a build phase")
        }
    }
}

extension XCSchema.FolderExceptionSet.Kind: XCJSON.StringCodable {
    var encodableStringRepresentation: String {
        switch self {
            case .target: "target"
            case .buildPhase: "build-phase"
        }
    }

    public init(encodableStringRepresentation string: String) throws {
        switch string {
            case "target": self = .target
            case "build-phase": self = .buildPhase
            default: throw NSError("Unexpected value for folder exception set kind \(string.smartQuoted)")
        }
    }
}
