//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// Used to signal the feature requirements of a project file.
    ///
    /// When opening the file, if the decoder encounters an unknown capability, it stops the decode, and throws an error message using the capability's string value as a major portion of the error message.
    public struct Capability: Hashable, XCJSON.CodableOrderable, Sendable {
        public static let knownCapabilityForTesting = Self(capabilityDescription: "known capability for testing")
        public static let knownCapabilities: [Self] = [knownCapabilityForTesting]
        public var capabilityDescription: String // This will bre presented to the user in error messages, so it should be something like "glow in the dark", not "glowInTheDark".
        public init(capabilityDescription: String) {
            self.capabilityDescription = capabilityDescription
        }

        public static func lessThanForCoding(lhs: Self, rhs: Self) -> Bool {
            lhs.capabilityDescription < rhs.capabilityDescription
        }

        public var isSatisfied: Bool {
            Self.knownCapabilities.contains(self)
        }
    }
}

extension XCSchema.Capability: XCJSON.StringCodable {
    public var encodableStringRepresentation: String {
        capabilityDescription
    }

    public init(encodableStringRepresentation: String) throws {
        self.init(capabilityDescription: encodableStringRepresentation)
    }
}
