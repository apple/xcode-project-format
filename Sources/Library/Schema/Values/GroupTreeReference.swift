//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// References an item in the groups and files tree of the project.
    ///
    /// May be object-id or name-path based.
    ///
    /// Name-path references are an array of names forming a path, where each name is the name of a reference in the groups and files tree. Notably those names can be different from the file system objects they represent. And the group tree can significantly diverge from the file system hierarchy. Many projects have groups with names like "Command Line Tool" where the directory name is "CommandLineTool", or the group's sub-items reside in a different part of the file system than the group's directory.
    ///
    /// Names in the groups and files tree don't have to respect file system conventions, so they can have values like ".." or contain "/". The `NamePath` type handles all of this ambiguity.
    ///
    /// Two elements in a group can also have the same name, so these name paths are not always unique. When a name path cannot uniquely resolve a file reference, an `.objectID` style reference must be used instead.
    public enum GroupTreeReference: Equatable, CustomStringConvertible, Sendable {
        case objectID(ObjectID)
        case namePath(NamePath)

        public var description: String {
            switch self {
                case let .objectID(objectID): Self.idSignalingPrefix + objectID.encodableStringRepresentation
                case let .namePath(namePath): namePath.description
            }
        }
    }
}

extension XCSchema.GroupTreeReference: XCJSON.Codable {
    package static let idSignalingPrefix = "id:"

    private enum Encoding {
        case string(String)
        case namePathComponents([NamePathComponent])
    }

    private var encoding: Encoding {
        switch self {
            case let .objectID(objectID):
                return .string(Self.idSignalingPrefix + objectID.encodableStringRepresentation)
            case let .namePath(namePath):
                if let string = namePath.losslessPathRepresentation, !string.hasPrefix(Self.idSignalingPrefix) {
                    return .string(string)
                } else {
                    return .namePathComponents(namePath.components)
                }
        }
    }

    package func encode(with coder: XCJSON.Encoder) throws {
        switch encoding {
            case let .string(string):
                coder.encodePrimitive(string)
            case let .namePathComponents(components):
                try components.encode(with: coder)
        }
    }

    package init(with coder: XCJSON.Decoder) throws {
        if coder.currentNodeType == .string {
            let string: String = try coder.decodePrimitive()
            if let objectID = string.droppingRequiredPrefix(Self.idSignalingPrefix) {
                self = .objectID(XCSchema.ObjectID(String(objectID)))
            } else {
                self = try .namePath(XCSchema.NamePath(losslessPathRepresentation: string))
            }
        } else {
            self = try .namePath(.init(components: .init(with: coder)))
        }
    }

    internal var encodesToString: Bool {
        switch encoding {
            case .string: true
            case .namePathComponents: false
        }
    }
}


