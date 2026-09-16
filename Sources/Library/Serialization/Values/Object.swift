//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation

extension XCJSON {
    package struct Object: Hashable, Sendable {
        package var fieldsOrComments: [FieldOrComment]

        package init(_ fieldsOrComments: [FieldOrComment]) {
            self.fieldsOrComments = fieldsOrComments
        }
    }
}
