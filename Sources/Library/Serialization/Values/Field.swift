//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0 with Runtime Library Exception
// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
//
//===----------------------------------------------------------------------===//

import Foundation


extension XCJSON {
    package struct Field: Hashable, Sendable {
        package var key: String
        package var value: Value

        package init(_ key: String, _ value: Value) {
            self.key = key
            self.value = value
        }
    }
}
