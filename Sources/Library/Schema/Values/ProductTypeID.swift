//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// Specifies a target's product type, like "framework", "application", or "tool".
    public struct ProductTypeID: XCSchema.TypedStringWrapper, Sendable {
        public var productTypeID: String

        public init(productTypeID: String) {
            self.productTypeID = productTypeID
        }

        public init(rawValue: String) {
            self.init(productTypeID: rawValue)
        }

        public var rawValue: String {
            productTypeID
        }

        package static let abbreviatablePrefix = "com.apple.product-type."
        public var abbreviatedRepresentation: String? {
            let abbreviatable = productTypeID.hasPrefix(Self.abbreviatablePrefix)
            return abbreviatable ? productTypeID.droppingPrefix(Self.abbreviatablePrefix) : nil
        }

        public init(abbreviatedRepresentation: String) {
            self.productTypeID = Self.abbreviatablePrefix + abbreviatedRepresentation
        }
    }
}


