//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation


extension XCSchema {
    /// The kind of product produced by a Swift package, used when establishing target dependencies.
    public enum SwiftPackageProductType: String, XCJSON.StringCodable, Sendable {
        case other = "other"
        case buildToolPlugin = "build-tool-plugin"
    }
}
