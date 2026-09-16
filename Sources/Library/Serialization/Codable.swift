//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation


extension XCJSON {
    package typealias Codable = Encodable & Decodable
    package typealias InlineKeyedCodable = InlineKeyedEncodable & InlineKeyedDecodable
}

extension NSError {
    package static let xcodeProjectFormatJSONCodingPathUserInfoKey = "XcodeProjectFormat.xcodeProjectFormatJSONCodingPath"
}
