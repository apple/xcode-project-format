//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// Describes what build styles a build phase is eligible to run in.
    ///
    /// Some copy and script phases are commonly marked to run only during install, for example to install a man page for a command-line tool.
    public enum BuildPhaseScope: String, XCJSON.StringCodable, Sendable {
        case always = "always"
        case install = "install"
    }
}
