//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation


extension XCSchema {
    /// Identifies an object that will be instantiated from the file system content discovered under a folder.
    ///
    /// Specifically, identifies a ``Reference``, discovered under a ``Folder``. Used as a key in ``FolderExceptionSet`` instances.
    public struct FolderMemberID: Hashable, XCJSON.CodableOrderable, Sendable {
        public var value: String

        public init(value: String) {
            self.value = value
        }

        public static func lessThanForCoding(lhs: XCSchema.FolderMemberID, rhs: XCSchema.FolderMemberID) -> Bool {
            lhs.value < rhs.value
        }
    }
}

extension XCSchema.FolderMemberID: ExpressibleByStringLiteral {
    public init(stringLiteral: StringLiteralType) {
        self.value = stringLiteral
    }
}


extension XCSchema.FolderMemberID: XCJSON.StringCodable {
    public var encodableStringRepresentation: String {
        value
    }

    public init(encodableStringRepresentation string: String) throws {
        value = string
    }
}
