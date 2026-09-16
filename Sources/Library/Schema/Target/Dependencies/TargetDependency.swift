//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation


extension XCSchema {
    /// Specifies a dependency from a local target in the project on another target or package.
    public enum TargetDependency: Equatable, Sendable {
        case localTarget(XCSchema.LocalTargetReference, Set<PlatformFilter>)
        case remoteTarget(XCSchema.RemoteTarget, Set<PlatformFilter>)
        case package(XCSchema.SwiftPackageProductReference, Set<PlatformFilter>)
    }
}

extension XCSchema.TargetDependency: XCJSON.Codable {
    private enum Kind: String, XCJSON.StringCodable {
        case localTarget
        case remoteTarget
        case package
    }

    private var kind: Kind {
        switch self {
            case .localTarget: .localTarget
            case .remoteTarget: .remoteTarget
            case .package: .package
        }
    }

    package func encode(with coder: XCJSON.Encoder) throws {
        if case let .localTarget(content, filters) = self, !filters.hasContent {
            coder.encodePrimitive(content.targetName)
        } else {
            let container = coder.openKeyedContainer(density: .compact)
            let platforms: Set<XCSchema.PlatformFilter>
            try container.encode(kind, for: "kind", defaultValue: .localTarget)
            switch self {
                case let .remoteTarget(content, filters):
                    try container.encode(inline: content)
                    platforms = filters
                case let .package(content, filters):
                    try container.encode(inline: content)
                    platforms = filters
                case let .localTarget(content, filters):
                    try container.encode(content, for: "target", unconditionally: .affirmative)
                    platforms = filters
            }
            try container.encode(platforms, for: "platforms", defaultValue: [], density: .compact)
        }
    }

    package init(with coder: XCJSON.Decoder) throws {
        if coder.currentNodeType == .string {
            let localTarget = try XCSchema.LocalTargetReference(targetName: coder.decodePrimitive())
            self = .localTarget(localTarget, [])
        } else {
            let container = try coder.openKeyedContainer()
            let filters: Set<XCSchema.PlatformFilter> = try container.decode("platforms", defaultValue: [])
            switch try container.decode("kind", defaultValue: Kind.localTarget) {
                case .remoteTarget:
                    let content: XCSchema.RemoteTarget = try container.decodeInline()
                    self = .remoteTarget(content, filters)
                case .package:
                    let content: XCSchema.SwiftPackageProductReference = try container.decodeInline()
                    self = .package(content, filters)
                case .localTarget:
                    self = try .localTarget(container.decode("target"), filters)
            }
        }
    }
}
