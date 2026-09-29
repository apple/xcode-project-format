//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0 with Runtime Library Exception
// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
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
