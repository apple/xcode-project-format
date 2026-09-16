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
    /// A name-based reference combines a `target`, a build phase `kind`, and an optional build phase `name` — enough to uniquely identify the build phase without needing to look up its ID.
    public enum ProjectBuildPhaseReference: Equatable, CustomStringConvertible, Sendable {
        case named(target: LocalTargetReference, kind: BuildPhase.Kind, name: String?)
        case objectID(ObjectID)

        internal var groupTreeReferenceRepresentation: GroupTreeReference {
            switch self {
                case let .named(target, kind, name):
                    let components = [
                        target.targetName,
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


extension XCSchema.ProjectBuildPhaseReference: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        let components = value.components(separatedBy: "/").map { name in
            XCSchema.NamePathComponent.child(name)
        }
        try! self.init(namePath: XCSchema.NamePath(components: components))
    }
}

extension XCSchema.ProjectBuildPhaseReference: XCJSON.Codable {
    package func encode(with coder: XCJSON.Encoder) throws {
        try groupTreeReferenceRepresentation.encode(with: coder)
    }

    internal init(namePath path: NamePath) throws {
        if let targetName = path.components.first?.childName {
            let target = XCSchema.LocalTargetReference(targetName: targetName)
            let rest = try XCSchema.TargetBuildPhaseReference.parse(namePath: path.components.dropFirst())
            self = .named(target: target, kind: rest.kind, name: rest.name)
        } else {
            throw NSError("Invalid project relative build phase reference \(path.description.smartQuoted)")
        }
    }

    internal init(groupTreeReferenceRepresentation path: GroupTreeReference) throws {
        switch path {
            case let .objectID(objectID):
                self = .objectID(objectID)
            case let .namePath(path):
                try self.init(namePath: path)
        }
    }

    package init(with coder: XCJSON.Decoder) throws {
        try self.init(groupTreeReferenceRepresentation: GroupTreeReference(with: coder))
    }
}
