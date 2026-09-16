//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// Properties common to all build phase types.
    ///
    /// Some build phase types, like script, copy files, and AppleScript, have additional phase-specific properties.
    public struct BuildPhaseProperties: Equatable, Sendable {
        public var name: String?
        public var objectID: ObjectID?
        public init(objectID: ObjectID?, name: String?) {
            self.objectID = objectID
            self.name = name
        }

        package static let defaultInstance = Self(objectID: nil, name: nil)

        internal var everythingIsDefault: Bool {
            self == Self.defaultInstance
        }
    }
}

extension XCSchema.BuildPhaseProperties: XCJSON.InlineKeyedCodable {
    package func encode(with container: XCJSON.Encoder.KeyedContainer) throws {
        try container.encode(objectID, for: "id", defaultValue: Self.defaultInstance.objectID)
        try container.encode(name, for: "name", defaultValue: Self.defaultInstance.name)
    }

    package init(with container: XCJSON.Decoder.KeyedContainer) throws {
        objectID = try container.decode("id", defaultValue: Self.defaultInstance.objectID)
        name = try container.decode("name", defaultValue: Self.defaultInstance.name)
    }

    var printingDensity: XCJSON.PrintingDensity? {
        .compact
    }
}

