//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation


package enum XCJSON {}

extension XCJSON.Value: ExpressibleByNilLiteral {
    package init(nilLiteral: ()) {
        self = .null
    }
}

extension XCJSON.Value: ExpressibleByBooleanLiteral {
    package init(booleanLiteral value: BooleanLiteralType) {
        self = .boolean(value)
    }
}

extension XCJSON.Value: ExpressibleByIntegerLiteral {
    package init(integerLiteral value: IntegerLiteralType) {
        self = .integer(value)
    }
}

extension XCJSON.Value: ExpressibleByFloatLiteral {
    package init(floatLiteral value: FloatLiteralType) {
        self = .double(value)
    }
}

extension XCJSON.Value: ExpressibleByStringLiteral {
    package init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}

extension XCJSON.Value: ExpressibleByArrayLiteral {
    package init(arrayLiteral elements: XCJSON.Value...) {
        self = .array(elements.map(XCJSON.ValueOrComment.value))
    }
}

extension XCJSON.Value: ExpressibleByDictionaryLiteral {
    package init(dictionaryLiteral elements: (String, XCJSON.Value)...) {
        let fields = elements.map(XCJSON.Field.init).map(XCJSON.FieldOrComment.field)
        self = .object(fields)
    }
}
