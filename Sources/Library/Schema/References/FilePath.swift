//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation

extension XCSchema {
    /// A file path, plus a virtual base to resolve it against.
    ///
    /// The path is relative to the base, unless the base is `.absolute`, in which case the path is itself absolute. During path resolution in the context of a fully instantiated project, the virtual bases like `.group` or `.project` are resolvable using the context of the parent references. `XcodeProjectFormat` does not have the necessary context to do path resolution; it only specifies the parameters.
    public struct FilePath: Equatable, ExpressibleByStringLiteral, Sendable {
        /// The virtual base to resolve a relative file path against.
        ///
        /// These bases don't have actual values until path resolution in a fully instantiated project in Xcode.
        public enum Base: Hashable, Sendable {
            case absolute
            case group
            case project
            case developer
            case buildProducts
            case sdk
            case sourceRoot(String)
        }

        public let base: Base // Let to guard init's constraints
        public let path: String // Let to guard init's constraints
        public init(base: Base, path: String) throws {
            // This matches Xcode's long standing treatment of absolute paths, which expands leading ~ in file paths.
            let isAbsolutePath = path.hasPrefix("/") || path.hasPrefix("~")
            try require(isAbsolutePath == (base == .absolute), orThrow: "Base disagrees with absoluteness of path: \(path)")
            self.base = base
            self.path = path
        }

        public init(stringLiteral value: StringLiteralType) {
            try! self.init(stringRepresentation: value)
        }
    }
}


extension XCSchema.FilePath: XCJSON.InlineKeyedCodable {
    public var stringRepresentation: String {
        if let expansionVariable = base.builtInExpansionVariable {
            return "<\(expansionVariable)>/\(path)"
        } else if let expansionVariable = base.buildSetting {
            let escapedVariable = expansionVariable.escaping(">")
            return "<USER:\(escapedVariable)>/\(path)"
        } else {
            return path.escaping("<")
        }
    }

    private static let sourceRootPrefix = "<USER:"
    private init?(sourceRootEncoding string: String) throws {
        if let remaining = string.droppingRequiredPrefix(Self.sourceRootPrefix) {
            switch remaining.unescapingUntilError(escapedCharacter: ">") {
                case let .unescapedSequence(unescaped: unescaped, remaining: remaining):
                    let path = try remaining.droppingRequiredPrefix("/").unwrap(orThrow: "Invalid filePathEncoding \(string.smartQuoted) - missing initial path separator")
                    try self.init(base: .sourceRoot(unescaped), path: path)
                case .complete, .unresolvedEscape:
                    throw NSError("Invalid filePathEncoding \(string.smartQuoted)")
                case .invalidEscapeSequence(let character):
                    throw NSError("Invalid escape sequence \("\\\(character)".smartQuoted) in \(string.smartQuoted)")
            }
        } else {
            return nil
        }
    }

    public init(stringRepresentation string: String) throws {
        if let result = try Self(sourceRootEncoding: string) {
            self = result
        } else if string.hasPrefix("<") {
            let endRange = try string.range(of: ">/").unwrap(orThrow: "Unterminated path base")
            let expansionVariable = String(string[..<endRange.lowerBound].dropFirst())
            let path = String(string[endRange.upperBound...])
            let base = try Base(expansionVariable: expansionVariable).unwrap(orThrow: "Invalid path base: \(expansionVariable.smartQuoted)")
            try self.init(base: base, path: path)
        } else {
            try self.init(base: string.hasPrefix("/") ? .absolute : .group, path: string.unescaping("<"))
        }
    }

    package func encode(with container: XCJSON.Encoder.KeyedContainer) throws {
        try container.encode(stringRepresentation, for: "path", defaultValue: "")
    }

    package init(with container: XCJSON.Decoder.KeyedContainer) throws {
        try self.init(stringRepresentation: container.decode("path", defaultValue: ""))
    }
}

extension XCSchema.FilePath.Base {
    package var builtInExpansionVariable: String? {
        switch self {
            case .absolute, .group, .sourceRoot: nil
            case .project: "PROJECT"
            case .developer: "DEVELOPER"
            case .buildProducts: "PRODUCTS"
            case .sdk: "SDK"
        }
    }

    var buildSetting: String? {
        switch self {
            case .absolute, .group, .project, .developer, .buildProducts, .sdk: nil
            case .sourceRoot(let variable): variable
        }
    }

    init?(expansionVariable: String) {
        switch expansionVariable {
            case "PROJECT": self = .project
            case "DEVELOPER": self = .developer
            case "PRODUCTS": self = .buildProducts
            case "SDK": self = .sdk
            default: return nil
        }
    }
}

