//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCSchema {
    /// Represents a file type identifier known to Swift Build.
    ///
    /// The `fileTypeID` is a bespoke string value from Swift Build, with values like `sourcecode.swift` or `sourcecode.c.objc`. They influence Xcode's editor selection and behavior, and Swift Build's build rule selection.
    public struct FileTypeID: XCSchema.TypedStringWrapper, Sendable {
        public var fileTypeID: String

        public init(fileTypeID: String) {
            self.fileTypeID = fileTypeID
        }

        public init(rawValue: String) {
            self.init(fileTypeID: rawValue)
        }

        public var rawValue: String {
            fileTypeID
        }
    }
}


