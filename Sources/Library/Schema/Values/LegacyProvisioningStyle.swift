//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// When a project is using legacy provisioning, specifies automatic or manual provisioning.
    public enum LegacyProvisioningStyle: String, XCJSON.StringCodable, Sendable {
        case automatic = "automatic"
        case manual = "manual"
    }
}
