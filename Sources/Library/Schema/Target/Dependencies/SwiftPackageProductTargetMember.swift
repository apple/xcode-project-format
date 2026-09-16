//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// Maps a product from a Swift package into a build phase in a target.
    public struct SwiftPackageProductTargetMember: Equatable, Sendable {
        public var packageProduct: SwiftPackageProductReference
        public var buildFile: TargetBuildFile

        public init(packageProduct: SwiftPackageProductReference, buildFile: TargetBuildFile) {
            self.packageProduct = packageProduct
            self.buildFile = buildFile
        }
    }
}

extension XCSchema.SwiftPackageProductTargetMember {
    private var buildFileOrderComponent: some Comparable {
        switch buildFile.buildPhase {
            case .named(kind: let kind, name: let name):
                return LexicographicalOrder3(kind.encodableStringRepresentation, name ?? "", "")
            case .objectID(let objectID):
                return LexicographicalOrder3("", "", objectID.encodableStringRepresentation)
        }
    }

    var encodingOrder: some Comparable {
        return LexicographicalOrder(
            packageProduct.encodingOrder,
            buildFileOrderComponent,
        )
    }
}

extension XCSchema.SwiftPackageProductTargetMember: XCJSON.Codable {
    package func encode(with coder: XCJSON.Encoder) throws {
        let container = coder.openKeyedContainer()
        try container.encode(inline: packageProduct)
        try container.encode(buildFile, for: "build-phase", unconditionally: .affirmative)
    }

    package init(with coder: XCJSON.Decoder) throws {
        let container = try coder.openKeyedContainer()
        packageProduct = try container.decodeInline()
        buildFile = try container.decode("build-phase")
    }
}
