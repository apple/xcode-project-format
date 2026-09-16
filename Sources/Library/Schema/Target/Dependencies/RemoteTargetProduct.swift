//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// Specifies the information needed to look up the product of a target from an external project reference.
    ///
    /// Used to map the output of a remote target into the inputs of a local target, usually in a link or copy build phase.
    public struct RemoteProduct: Equatable, Sendable {
        public var project: GroupTreeReference
        public var target: String
        public var productID: ObjectID
        public var path: String
        public var fileType: FileTypeID?
        public var buildFiles: [ProjectBuildFile]

        public init(project: GroupTreeReference, target: String, productID: ObjectID, path: String, fileType: FileTypeID?, buildFiles: [ProjectBuildFile]) {
            self.project = project
            self.target = target
            self.productID = productID
            self.path = path
            self.fileType = fileType
            self.buildFiles = buildFiles
        }

        public var suggestedEncodingOrder: some Comparable {
            LexicographicalOrder(path, target, productID.rawValue, fileType?.fileTypeID ?? "")
        }
    }
}

extension XCSchema.RemoteProduct: XCJSON.InlineKeyedCodable {
    package func encode(with container: XCJSON.Encoder.KeyedContainer) throws {
        let pathIsName = path.pathComponents.count == 1
        try container.encode(path, for: pathIsName ? "name" : "path", unconditionally: .affirmative)
        try container.encode(project, for: "project", unconditionally: .affirmative)
        try container.encode(target, for: "target", unconditionally: .affirmative)
        try container.encode(productID, for: "product-id", unconditionally: .affirmative)
        try container.encode(fileType, for: "type", defaultValue: nil)
        try container.encode(buildFiles, for: "target-membership", unconditionally: .affirmative)
    }

    package init(with container: XCJSON.Decoder.KeyedContainer) throws {
        path = try container.decodeIfPresent("name") ?? container.decode("path")
        project = try container.decode("project")
        target = try container.decode("target")
        productID = try container.decode("product-id")
        fileType = try container.decodeIfPresent("type")
        buildFiles = try container.decode("target-membership")
    }
}
