//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation


extension XCJSON {
    package struct Comment: Hashable, Sendable {
        package let style: CommentStyle
        package let content: String
        package init(style: CommentStyle, content: String) throws {
            if style == .block {
                if content.contains("/*") || content.contains("*/") {
                    throw NSError("Comment contains internal terminators")
                }
            }
            self.style = style
            self.content = content
        }

        package var allowsCompactPrinting: Bool {
            return (style == .block) && !content.anySatisfy(\.isJSONLineSeparator)
        }
    }
}
