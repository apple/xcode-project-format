//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCJSON {
    package protocol Decodable {
        init(with coder: XCJSON.Decoder) throws
    }
}


extension XCJSON {
    package protocol InlineKeyedDecodable: XCJSON.Decodable {
        init(with container: XCJSON.Decoder.KeyedContainer) throws
    }
}

extension XCJSON.InlineKeyedDecodable {
    package init(with coder: XCJSON.Decoder) throws {
        try self.init(with: coder.openKeyedContainer())
    }
}
