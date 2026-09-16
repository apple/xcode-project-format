//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// When a copy build phase targets a bundle, this value specifies which of the semantic parts of the bundle the copy should land in.
    public enum BundleBasePath: String, XCJSON.StringCodable, Sendable {
        case root = "root"

        // Bundle Directories
        case productDir = "build-products-directory"
        case sharedFrameworksDir = "shared-frameworks-directory"
        case sharedSupportDir = "shared-support-directory"
        case javaDir = "java-directory"
        case frameworksDir = "frameworks-directory"
        case resourcesDir = "resources-directory"
        case pkgInfo = "package-info-file"
        case appleScriptsDir = "apple-scripts-directory"
        case plugInsDir = "plugins-directory"
        case privateHeadersDir = "private-headers-directory"
        case headersDir = "headers-directory"
        case contentsDir = "contents-directory"
        case executablesDir = "executables-directory" // Note, this is the "/MacOS" directory on macOS, not the "Executables" directory that many apps tend to use.

        // Bundle Files
        case infoPlist = "info-plist-file"
        case mainExecutable = "main-executable-file"
        case mainExecutableShallow = "shallow-main-executable-file"
    }
}
