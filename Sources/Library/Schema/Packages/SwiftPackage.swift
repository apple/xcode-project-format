//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// A reference to either a remote, or local Swift package along with its traits.
    public struct SwiftPackage: Equatable, Sendable {
        public var location: XCSchema.SwiftPackageLocation
        public var traits: [String]

        public init(location: XCSchema.SwiftPackageLocation, traits: [String]) {
            self.location = location
            self.traits = traits
        }
    }
}

extension XCSchema.SwiftPackage: XCJSON.Codable {
    package func encode(with coder: XCJSON.Encoder) throws {
        let container = coder.openKeyedContainer()
        try container.encode(inline: location)
        try container.encode(traits, for: "traits", defaultValue: [])
    }

    package init(with coder: XCJSON.Decoder) throws {
        let container = try coder.openKeyedContainer()
        location = try container.decodeInline()
        traits = try container.decode("traits", defaultValue: [])
    }
}
