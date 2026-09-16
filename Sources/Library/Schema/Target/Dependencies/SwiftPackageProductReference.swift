//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// Specifies enough information to look up a product produced by a Swift package.
    ///
    /// Usually used to form an explicit target dependency, or to make the product of a package an input to a link or copy build phase.
    public struct SwiftPackageProductReference: Hashable, Sendable {
        public var objectID: ObjectID?
        public var package: SwiftPackageName?
        public var productName: String
        public var productType: XCSchema.SwiftPackageProductType

        public init(objectID: ObjectID?, package: SwiftPackageName?, productName: String, productType: XCSchema.SwiftPackageProductType) {
            self.objectID = objectID
            self.package = package
            self.productName = productName
            self.productType = productType
        }

        var encodingOrder: some Comparable {
            return LexicographicalOrder(
                package?.packageName ?? "",
                productName,
                productType.encodableStringRepresentation,
            )
        }
    }
}

extension XCSchema.SwiftPackageProductReference: XCJSON.InlineKeyedCodable {
    package func encode(with container: XCJSON.Encoder.KeyedContainer) throws {
        try container.encode(package, for: "package", defaultValue: nil)
        try container.encode(objectID, for: "id", defaultValue: nil)
        try container.encode(productName, for: "product-name", unconditionally: .affirmative)
        try container.encode(productType, for: "product-type", defaultValue: .other)
    }

    package init(with container: XCJSON.Decoder.KeyedContainer) throws {
        self.package = try container.decode("package", defaultValue: nil)
        self.objectID = try container.decode("id", defaultValue: nil)
        self.productName = try container.decode("product-name")
        self.productType = try container.decode("product-type", defaultValue: .other)
    }
}

