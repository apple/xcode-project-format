//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0 with Runtime Library Exception
// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
//
//===----------------------------------------------------------------------===//

import Foundation
import Testing
import XcodeProjectFormat

private struct ParentValueProbe: XCJSON.Decodable {
    init(with coder: XCJSON.Decoder) throws {
        let container = try coder.openKeyedContainer()
        let _: String = try container.decode("name")

        #expect(coder.currentNodeType == .object)
        _ = try coder.openKeyedContainer()
    }
}

@Test func restoresParentValueAfterDecodingChild() throws {
    let _: ParentValueProbe = try XCJSON.Decoder.decode(
        data: Data(#"{"name":"App"}"#.utf8)
    )
}
