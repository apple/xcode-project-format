//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// A build configuration for a project, like "Debug" or "Release".
    public struct Configuration: Equatable, Sendable {
        public var name: ConfigurationName
        public var file: GroupTreeAnchoredReference?
        public var objectID: ObjectID?

        public init(name: ConfigurationName, file: GroupTreeAnchoredReference?, objectID: ObjectID?) {
            self.name = name
            self.file = file
            self.objectID = objectID
        }

        public var isSpecialized: Bool {
            file != nil || objectID != nil
        }
    }
}

extension XCSchema.Configuration: XCJSON.Codable {
    package func encode(with coder: XCJSON.Encoder) throws {
        if ((objectID == nil) && (file == nil)) {
            try coder.encodePrimitive(name)
        } else {
            let container = coder.openKeyedContainer()
            try container.encode(objectID, for: "id", defaultValue: nil)
            try container.encode(name, for: "name", unconditionally: .affirmative)
            try container.encode(file, for: "file", defaultValue: nil,  density: .compact)
        }
    }

    package init(with coder: XCJSON.Decoder) throws {
        if coder.currentNodeType == .string {
            name = try coder.decodePrimitive()
        } else {
            let container = try coder.openKeyedContainer()
            objectID = try container.decode("id", defaultValue: nil)
            name = try container.decode("name")
            file = try container.decode("file", defaultValue: nil)
        }
    }
}
