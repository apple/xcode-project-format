//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation

extension XCSchema {
    /// Refers to a build phase in a target, either by name or by an explicit build phase ID when the names aren't distinct enough to support a name-based reference.
    ///
    /// A name-based reference combines a build phase `kind` and an optional build phase `name` — enough to uniquely identify the build phase without needing to look up its ID. The target is presumed to be externally known when the name-based value is used.
    public enum TargetBuildPhaseReference: Equatable, CustomStringConvertible, Sendable {
        case named(kind: BuildPhase.Kind, name: String?)
        case objectID(ObjectID)

        internal var groupTreeReferenceRepresentation: GroupTreeReference {
            switch self {
                case let .named(kind, name):
                    let components = [
                        kind.encodableStringRepresentation,
                        name
                    ].compacted()
                    return .namePath(NamePath(childNameComponents: components))
                case let .objectID(objectID):
                    return .objectID(objectID)
            }
        }

        public var description: String {
            groupTreeReferenceRepresentation.description
        }
    }
}

extension XCSchema.TargetBuildPhaseReference: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        let components = value.components(separatedBy: "/").map { name in
            XCSchema.NamePathComponent.child(name)
        }
        try! self.init(groupTreeReferenceRepresentation: GroupTreeReference.namePath(NamePath(components: components)))
    }
}

extension XCSchema.TargetBuildPhaseReference: XCJSON.Codable {
    package func encode(with coder: XCJSON.Encoder) throws {
        try groupTreeReferenceRepresentation.encode(with: coder)
    }

    static func parse(namePath path: some BidirectionalCollection<NamePathComponent>) throws -> (kind: BuildPhase.Kind, name: String?) {
        func error() -> NSError {
            NSError("Invalid target relative build phase reference: \(NamePath(components: Array(path)).description.smartQuoted)")
        }
        if (1...2).contains(path.count) {
            let kindName = try (path.first?.childName).unwrap(orThrow: error())
            let kind = try BuildPhase.Kind(rawValue: kindName).unwrap(orThrow: error())
            if path.count == 2 {
                let name = try (path.last?.childName).unwrap(orThrow: error())
                return (kind, name)
            } else {
                return (kind, nil)
            }
        } else {
            throw error()
        }
    }

    internal init(groupTreeReferenceRepresentation path: GroupTreeReference) throws {
        switch path {
            case let .objectID(objectID):
                self = .objectID(objectID)
            case let .namePath(path):
                let args = try Self.parse(namePath: path.components)
                self = try .named(kind: args.kind, name: args.name)
        }
    }

    package init(with coder: XCJSON.Decoder) throws {
        try self.init(groupTreeReferenceRepresentation: GroupTreeReference(with: coder))
    }
}
