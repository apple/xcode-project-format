//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// Specifies the information needed to look up a target from an external project reference.
    ///
    /// A `RemoteTarget` is used to represent target dependencies on targets in other projects.
    public struct RemoteTarget: Equatable, Sendable {
        public var project: GroupTreeReference
        public var target: String
        public var targetID: ObjectID

        public init(project: GroupTreeReference, target: String, targetID: ObjectID) {
            self.project = project
            self.target = target
            self.targetID = targetID
        }
    }
}

extension XCSchema.RemoteTarget: XCJSON.InlineKeyedCodable {
    package func encode(with container: XCJSON.Encoder.KeyedContainer) throws {
        try container.encode(project, for: "project", unconditionally: .affirmative)
        try container.encode(target, for: "target", unconditionally: .affirmative)
        try container.encode(targetID, for: "target-id", unconditionally: .affirmative)
    }

    package init(with container: XCJSON.Decoder.KeyedContainer) throws {
        project = try container.decode("project")
        target = try container.decode("target")
        targetID = try container.decode("target-id")
    }
}
