//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCJSON {
    package protocol Encodable {
        func encode(with coder: XCJSON.Encoder) throws
    }
}

extension XCJSON {
    package protocol InlineKeyedEncodable: XCJSON.Encodable {
        func encode(with container: XCJSON.Encoder.KeyedContainer) throws
    }
}

extension XCJSON.InlineKeyedEncodable {
    package func encode(with coder: XCJSON.Encoder) throws {
        try encode(with: coder.openKeyedContainer())
    }
}
