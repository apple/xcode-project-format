//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation

extension XCSchema {
    /// A simple wrapper around `String` used to more ergonomically encode things like a shell script build phase's script.
    package struct MultilineText: Hashable {
        package var text: String
        package init(text: String) {
            self.text = text
        }
    }
}

extension XCSchema.MultilineText: XCJSON.Codable {
    package func encode(with coder: XCJSON.Encoder) throws {
        let lines = text.components(separatedBy: "\n")
        if (lines.count == 1) || (lines.count == 2 && lines[1] == "") {
            coder.encodePrimitive(text)
        } else {
            try lines.encode(with: coder)
        }
    }

    package init(with coder: XCJSON.Decoder) throws {
        if coder.currentNodeType == .string {
            text = try coder.decodePrimitive()
        } else {
            let lines = try Array<String>(with: coder)
            text = lines.joined(separator: "\n")
        }
    }
}
