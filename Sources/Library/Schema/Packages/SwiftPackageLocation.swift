//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// The location of a remote or local Swift package.
    public enum SwiftPackageLocation: Equatable, Sendable {
        case local(LocalSwiftPackage)
        case remote(RemoteSwiftPackage)

        enum Kind: String, XCJSON.StringCodable {
            case local = "local"
            case remote = "remote"
        }

        var kind: Kind {
            switch self {
                case .local: .local
                case .remote: .remote
            }
        }
    }
}

extension XCSchema.SwiftPackageLocation: XCJSON.InlineKeyedCodable {
    package func encode(with container: XCJSON.Encoder.KeyedContainer) throws {
        try container.encode(kind, for: "kind", unconditionally: .affirmative)
        switch self {
            case let .local(content):
                try container.encode(inline: content)
            case let .remote(content):
                try container.encode(inline: content)
        }
    }

    package init(with container: XCJSON.Decoder.KeyedContainer) throws {
        let kind: Kind = try container.decode("kind")
        switch kind {
            case .local: self = try .local(container.decodeInline())
            case .remote: self = try .remote(container.decodeInline())
        }
    }
}


