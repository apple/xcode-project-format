//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0 with Runtime Library Exception
// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
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
