//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation

fileprivate typealias UTF8Unit = Unicode.UTF8.CodeUnit
extension UTF8Unit {
    fileprivate static let newline: Self = 10
    fileprivate static let carriageReturn: Self = 13
    fileprivate static let tab: Self = 9
    fileprivate static let bell: Self = 7
    fileprivate static let formFeed: Self = 12
    fileprivate static let forwardSlash: Self = 47
    fileprivate static let backwardSlash: Self = 92
}

fileprivate typealias UTF16Unit = Unicode.UTF16.CodeUnit
extension UTF16Unit {
    fileprivate static let newline: Self = 10
    fileprivate static let carriageReturn: Self = 13
    fileprivate static let tab: Self = 9
    fileprivate static let bell: Self = 7
    fileprivate static let formFeed: Self = 12
    fileprivate static let forwardSlash: Self = 47
    fileprivate static let backwardSlash: Self = 92
}

extension Character {
    fileprivate static let newline: Self = "\n"
    fileprivate static let carriageReturn: Self = "\r"
    fileprivate static let lineSeparator: Self = "\u{2028}"
    fileprivate static let paragraphSeparator: Self = "\u{2029}"

    var isJSONLineSeparator: Bool {
        return (self == .newline)
            || (self == .carriageReturn)
            || (self == .lineSeparator)
            || (self == .paragraphSeparator)

    }
}

extension XCJSON {
    class Printer {
        private var utf8 = Data()
        private var depth: Int = 0
        private var currentPath = AbsolutePath.root
        private var printOnSingleLine = false
        private var explicitPrintingDensities: [AbsolutePath: PrintingDensity] = [:]
        private var root: XCJSON.Value

        private init(root: XCJSON.Value, explicitPrintingDensities: [AbsolutePath : PrintingDensity]) {
            self.explicitPrintingDensities = root.validate(densities: explicitPrintingDensities)
            self.root = root
        }

        private let literalEncoder: JSONEncoder = {
            var encoder = JSONEncoder()
            encoder.outputFormatting = [.withoutEscapingSlashes]
            return encoder
        }()

        fileprivate func append(_ string: StaticString) {
            string.withUTF8Buffer { bytes in
                utf8.append(contentsOf: bytes)
            }
        }

        fileprivate func append(_ bytes: some Collection<UInt8>) {
            utf8.append(contentsOf: bytes)
        }

        func emitNull() {
            append("null")
        }

        func emit(_ value: Bool) {
            append(value ? "true" : "false")
        }

        func emit(_ value: Int) {
            // Encoding an Int can't fail.
            utf8 += try! literalEncoder.encode(value)
        }

        func emit(_ value: Double) {
            // Encoding a Double can't fail.
            utf8 += try! literalEncoder.encode(value)
        }

        private func emit(_ value: String) {
            // Encoding a String can't fail.
            utf8 += try! literalEncoder.encode(value)
        }

        private func emit(_ value: Comment) {
            switch value.style {
                case .line:
                    precondition(!printOnSingleLine) // Validation should have discarded .compact suggestion.
                    append("// ")
                    for character in value.content {
                        if character.isJSONLineSeparator {
                            append("\n")
                            indentIfAtLineStart()
                            append("// ")
                        } else {
                            append(character.utf8)
                        }
                    }
                    indentIfAtLineStart()
                case .block:
                    let outdented = value.content.hasPrefix("\n")
                    append("/*")
                    if !outdented {
                        append(" ")
                    }
                    // value.content is known not to contain "/*" or "*/" terminators via its type constraints.
                    for character in value.content {
                        if character.isJSONLineSeparator {
                            precondition(!printOnSingleLine) // Validation should have discarded .compact suggestion.
                            append("\n")
                            indentIfAtLineStart()
                            if !outdented {
                                append("   ")
                            }
                        } else {
                            append(character.utf8)
                        }
                    }
                    if !outdented {
                        append(" ")
                    }
                    append("*/")
            }
        }

        func indentIfAtLineStart() {
            if utf8.isEmpty || utf8.last == .newline {
                for _ in 0..<depth {
                    append("  ")
                }
            }
        }

        private func emit(_ entries: [ValueOrComment]) {
            let valueCount = entries.count(where: \.isValue)
            var valueIndex = 0
            if printOnSingleLine && !entries.hasContent {
                append("[]")
            } else if printOnSingleLine {
                append("[ ")
                for entry in entries {
                    switch entry {
                        case let .value(content):
                            emit(content, path: currentPath.appending(valueIndex))
                            valueIndex += 1
                            if (valueIndex != valueCount) {
                                append(", ")
                            }
                        case let .comment(content):
                            emit(content)
                    }
                }
                append(" ]")
            } else {
                append("[\n")
                depth += 1
                for (entryIndex, entry) in entries.enumerated() {
                    indentIfAtLineStart()
                    switch entry {
                        case let .value(content):
                            emit(content, path: currentPath.appending(valueIndex))
                            valueIndex += 1
                            let prevObjectIsContainer = content.contentShape == .container
                            let prevObjectIsMultiline = (explicitPrintingDensities[currentPath.appending(valueIndex - 1)] != .compact)
                            let nextObjectIsContainer = (entryIndex < (entries.count - 1)) && entries[entryIndex + 1].contentShape == .container
                            let nextObjectIsMultiline = (explicitPrintingDensities[currentPath.appending(valueIndex)] != .compact)
                            if prevObjectIsContainer && prevObjectIsMultiline && nextObjectIsContainer && nextObjectIsMultiline {
                                append(", ")
                            } else {
                                append(",\n")
                            }
                        case let .comment(content):
                            emit(content)
                            append("\n")
                    }
                }
                depth -= 1
                indentIfAtLineStart()
                append("]")
            }
        }

        private func emit(_ field: Field) {
            emit(field.key)
            append(": ")
            emit(field.value, path: currentPath.appending(field.key))
        }

        private func emit(_ entries: [FieldOrComment]) {
            let lastFieldIndex = entries.lastIndex(where: \.isField)
            if printOnSingleLine && !entries.hasContent {
                append("{}")
            } else if printOnSingleLine {
                append("{ ")
                for (index, entry) in entries.enumerated() {
                    switch entry {
                        case let .field(content):
                            emit(content)
                            if (index != lastFieldIndex) {
                                append(", ")
                            }
                        case let .comment(content):
                            emit(content)
                    }
                }
                append(" }")
            } else {
                append("{\n")
                depth += 1
                for entry in entries {
                    indentIfAtLineStart()
                    switch entry {
                        case let .field(content):
                            emit(content)
                            append(",\n")
                        case let .comment(content):
                            emit(content)
                            append("\n")
                    }
                }
                depth -= 1
                indentIfAtLineStart()
                append("}")
            }
        }

        private func emit(_ object: XCJSON.Object) {
            emit(object.fieldsOrComments)
        }

        private func emit(_ value: XCJSON.Value, path: AbsolutePath) {
            let originalPath = currentPath
            let originalPrintOnSingleLine = printOnSingleLine
            self.currentPath = path
            self.printOnSingleLine = printOnSingleLine || explicitPrintingDensities[path] == .compact
            switch value {
                case .null: emitNull()
                case let .boolean(content): emit(content)
                case let .integer(content): emit(content)
                case let .double(content): emit(content)
                case let .string(content): emit(content)
                case let .array(content): emit(content)
                case let .object(content): emit(content)
            }
            self.currentPath = originalPath
            self.printOnSingleLine = originalPrintOnSingleLine
        }

        private func print() {
            emit(root, path: .root)
        }

        static func data(_ value: Value, options: XCJSON.EncodingOptions, explicitPrintingDensities: [AbsolutePath: PrintingDensity]) -> Data {
            let printer = Printer(root: value, explicitPrintingDensities: explicitPrintingDensities)
            printer.print()
            var utf8 = printer.utf8
            if options.addTrailingNewline {
                utf8.append(.newline)
            }
            return utf8
        }
    }
}

extension XCJSON {
    enum ContentShape {
        case scalar
        case container
        case comment
    }

}

extension XCJSON.ValueOrComment {
    var contentShape: XCJSON.ContentShape {
        switch self {
            case .value(let value): value.contentShape
            case .comment: .comment
        }
    }
}

extension XCJSON.Value {
    var contentShape: XCJSON.ContentShape {
        switch self {
            case .null, .boolean, .integer, .double, .string: .scalar
            case .array, .object: .container
        }
    }
}


extension XCJSON.Value {
    fileprivate func validate(densities unvalidated: [XCJSON.AbsolutePath: XCJSON.PrintingDensity]) -> [XCJSON.AbsolutePath: XCJSON.PrintingDensity] {
        var validated = unvalidated
        _ = self.validate(densities: &validated, path: .root, probingForAllowableCompactness: false)
        return validated
    }

    private struct ValidationResult {
        var allowCompactness: Bool
    }

    // If the client requested compact printing, but has internal values with newlines, or inline comments, then we can't do compact printing.
    // In order to avoid O(N*N) scans, scan once ahead of time with a single pass over the tree to find nodes that can't be compact, but has an
    // ancestor with a compact request, and if they're in contradiction, erase the request.
    private func validate(densities: inout [XCJSON.AbsolutePath: XCJSON.PrintingDensity], path: XCJSON.AbsolutePath, probingForAllowableCompactness probingAncestor: Bool) -> ValidationResult {
        let probingLocally = (densities[path] == .compact)
        let probingAncestorOrLocally = probingAncestor || probingLocally
        let result: ValidationResult
        switch self {
            case .null, .boolean, .integer, .double, .string:
                result = ValidationResult(allowCompactness: true)
            case let .array(content):
                var allChildrenAllowCompactness = true
                for (index, valueOrComment) in content.enumerated() {
                    switch valueOrComment {
                        case let .value(value):
                            let childResult = value.validate(densities: &densities, path: path.appending(index), probingForAllowableCompactness: probingAncestorOrLocally)
                            allChildrenAllowCompactness = allChildrenAllowCompactness && childResult.allowCompactness
                        case let .comment(comment):
                            allChildrenAllowCompactness = comment.allowsCompactPrinting
                    }
                }
                result = ValidationResult(allowCompactness: allChildrenAllowCompactness)
            case let .object(content):
                var allChildrenAllowCompactness = true
                for fieldOrComment in content.fieldsOrComments {
                    switch fieldOrComment {
                        case let .field(field):
                            let childResult = field.value.validate(densities: &densities, path: path.appending(field.key), probingForAllowableCompactness: probingAncestorOrLocally)
                            allChildrenAllowCompactness = allChildrenAllowCompactness && childResult.allowCompactness
                        case let .comment(comment):
                            allChildrenAllowCompactness = comment.allowsCompactPrinting
                    }
                }
                result = ValidationResult(allowCompactness: allChildrenAllowCompactness)
        }
        if probingLocally && !result.allowCompactness {
            densities[path] = nil
        }
        return result
    }
}
