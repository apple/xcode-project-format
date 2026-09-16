//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// A reference to a remote Swift package, along with version constraint information used to select a specific revision.
    public struct RemoteSwiftPackage: Equatable, Sendable {
        public var repositoryURL: String
        public var versionConstraint: SwiftPackageVersionConstraint?

        public init(repositoryURL: String, versionConstraint: SwiftPackageVersionConstraint?) {
            self.repositoryURL = repositoryURL
            self.versionConstraint = versionConstraint
        }
    }
}

extension XCSchema.RemoteSwiftPackage: XCJSON.InlineKeyedCodable {
    package func encode(with container: XCJSON.Encoder.KeyedContainer) throws {
        try container.encode(repositoryURL, for: "repository", unconditionally: .affirmative)
        try container.encode(versionConstraint, for: "version", defaultValue: nil)
    }

    package init(with container: XCJSON.Decoder.KeyedContainer) throws {
        repositoryURL = try container.decode("repository")
        versionConstraint = try container.decode("version", defaultValue: nil)
    }
}
