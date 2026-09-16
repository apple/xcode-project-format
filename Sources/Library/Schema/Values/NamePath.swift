//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation

extension XCSchema {
    /// A path through the groups and files tree via each reference's name.
    ///
    /// Specifically, via each ``Reference`` object's name.
    ///
    /// A `NamePath` represents the path to a `Reference` through a `Project` instance's groups and files tree starting at the project's `topLevelReferences` and matching nodes walking down the tree by name.
    ///
    /// For a `NamePath` to be a viable reference, the named elements in the path must unambiguously match the references at each level. This is enforced at decoding time in Xcode, and decodes will fail when names are ambiguous. A `NamePath` isn't a full reference specifier, it's used within other more complex types like a `GroupTreeReference` which allows specifying identifier based references to cut through name based ambiguity at the cost of legibility in the project file.
    ///
    /// Xcode has no constraints on names in the group tree. They can be distinct from file names, contain "/", or be "..". `NamePath` handles this complexity and can represent relative paths in the group tree while also encoding to a dense string representation for all typical project layouts.
    public struct NamePath: Equatable, CustomStringConvertible, Sendable {

        public var components: [NamePathComponent]

        public init(components: [NamePathComponent]) {
            self.components = components
        }

        init(childNameComponents: [String]) {
            self.components = childNameComponents.map { childNameComponent in
                .child(childNameComponent)
            }
        }


        public init(losslessPathRepresentation: String) throws {
            try self.init(components: losslessPathRepresentation.mapComponentsSeparated(byASCIICharacter: UInt8(ascii: "/")) { component in
                return try XCSchema.NamePathComponent(losslessStringEncoding: component, requiresSlashValidation: false)
            })
        }

        public var losslessPathRepresentation: String? {
            if components.hasContent {
                return components.completeMap(\.losslessStringEncoding)?.joined(separator: "/")
            } else {
                return nil
            }
        }

        public static func + (_ lhs: Self, _ rhs: Self) -> Self {
            .init(components: lhs.components + rhs.components)
        }

        public static func += (_ lhs: inout Self, _ rhs: Self) {
            lhs.components += rhs.components
        }

        public var description: String {
            components.map(\.description).joined(separator: "/")
        }
    }

    public enum NamePathComponent: Equatable, CustomStringConvertible, Sendable {
        public enum RelativeReference: String, Equatable, Sendable {
            case current = "."
            case parent = ".."
        }

        case relative(RelativeReference)
        case child(String)

        fileprivate init(losslessStringEncoding string: String, requiresSlashValidation: Bool = true) throws {
            if let relative = RelativeReference(rawValue: string) {
                self = .relative(relative)
            } else {
                if (!Self.canLosslesslyEncode(name: string, requiresSlashValidation: requiresSlashValidation, requiresRelativeReferenceValidation: false)) {
                    throw NSError("The value \(string.smartQuoted) isn't losslessly representable as a group path component")
                }
                self = .child(string)
            }
        }


        fileprivate static func canLosslesslyEncode(name: String, requiresSlashValidation: Bool = true, requiresRelativeReferenceValidation: Bool = true) -> Bool {
            return (!requiresSlashValidation || !name.contains("/"))
                && (!requiresRelativeReferenceValidation || (RelativeReference(rawValue: name) == nil))
        }

        var losslessStringEncoding: String? {
            switch self {
                case let .relative(relative): relative.rawValue
                case let .child(name): Self.canLosslesslyEncode(name: name) ? name : nil
            }
        }

        public var childName: String? {
            switch self {
                case .relative: nil
                case .child(let name): name
            }
        }

        public var description: String {
            switch self {
                case .relative(let relative): relative.rawValue
                case .child(let name): name
            }
        }
    }
}

extension XCSchema.NamePath: XCJSON.Codable {
    package func encode(with coder: XCJSON.Encoder) throws {
        if let string = losslessPathRepresentation {
            try string.encode(with: coder)
        } else {
            try components.encode(with: coder)
        }
    }

    package init(with coder: XCJSON.Decoder) throws {
        if coder.currentNodeType == .string {
            try self.init(losslessPathRepresentation: coder.decodePrimitive())
        } else {
            try self.init(components: coder.delegateDecoding())
        }
    }
}

extension XCSchema.NamePathComponent: XCJSON.Codable {
    package func encode(with coder: XCJSON.Encoder) throws {
        switch self {
            case let .relative(relative):
                coder.encodePrimitive(relative.rawValue)
            case let .child(name):
                if Self.canLosslesslyEncode(name: name) {
                    coder.encodePrimitive(name)
                } else {
                    let container = coder.openKeyedContainer()
                    try container.encode(name, for: "name", unconditionally: .affirmative)
                }
        }
    }

    package init(with coder: XCJSON.Decoder) throws {
        if coder.currentNodeType == .string {
            try self.init(losslessStringEncoding: coder.decodePrimitive())
        } else {
            let container = try coder.openKeyedContainer()
            self = try .child(container.decode("name"))
        }
    }
}

