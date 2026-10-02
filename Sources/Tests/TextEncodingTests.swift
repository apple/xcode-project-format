//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0 with Runtime Library Exception
// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
//
//===----------------------------------------------------------------------===//

import XcodeProjectFormat
import Foundation
import Testing

struct TextEncodingTests {
    @Test func decodingAnOutOfRangeIntegerThrows() {
        #expect(throws: NSError.self) {
            let _: XCSchema.TextEncoding = try XCJSON.Decoder.decode(data: Data("-1".utf8))
        }
    }

    @Test func encodingAnOutOfRangeRawValueThrows() {
        #expect(throws: NSError.self) {
            _ = try XCJSON.Encoder.data(for: XCSchema.TextEncoding(rawValue: String.Encoding(rawValue: UInt.max)), options: .defaultOptions)
        }
    }
}
