//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

package import Foundation

extension String {
    private var nsString: NSString { self as NSString }
    package var pathComponents: [String] { nsString.pathComponents }
    package var lastPathComponent: String { nsString.lastPathComponent }
    package var deletingLastPathComponent: String { nsString.deletingLastPathComponent }
    package var pathExtension: String { nsString.pathExtension }
    package var deletingPathExtension: String { nsString.deletingPathExtension }
    package func appendingPathComponent(_ str: String) -> String { nsString.appendingPathComponent(str) }
    package func appendingPathExtension(_ str: String) -> String? { nsString.appendingPathExtension(str) }
    package var expandingTildeInPath: String { nsString.expandingTildeInPath }
}

extension Bool {
    package var negated: Bool {
        !self
    }
}

extension NSError {
    package convenience init(_ description: String) {
        self.init(domain: "", code: -1, userInfo: [
            NSLocalizedDescriptionKey: description,
        ])
    }

    package convenience init(description: String, recoverySuggestion: String) {
        self.init(domain: "", code: -1, userInfo: [
            NSLocalizedDescriptionKey: description,
            NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion,
        ])
    }

    package func userInfo(for key: String) -> Any? {
        userInfo[key]
    }

    package func errorWith(userInfoKey key: String, value: Any) -> NSError {
        var userInfo = userInfo
        userInfo[key] = value
        return NSError(
            domain: domain,
            code: code,
            userInfo: userInfo
        )
    }

    package var localizedDescriptionCombinedWithRecoverySuggestionIfPresent: String {
        if let localizedRecoverySuggestion {
            return localizedDescription + "\n\n" + localizedRecoverySuggestion
        } else {
            return localizedDescription
        }
    }
}

extension Error {
    var asCocoaError: CocoaError? {
        (self as? CocoaError)
    }

    package var isNoSuchFile: Bool {
        return asCocoaError?.code == CocoaError.fileNoSuchFile
    }

    package var isFileExistsError: Bool {
        return asCocoaError?.code == CocoaError.fileWriteFileExists
    }
}

extension FileManager {
    package func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool, ignoringFileExistsErrors: Bool) throws {
        do {
            try createDirectory(atPath: path, withIntermediateDirectories: createIntermediates)
        } catch {
            let ignoreError = ignoringFileExistsErrors && error.isFileExistsError
            if !ignoreError {
                throw NSError("Could not create directory at \(path.quoted)")
            }
        }
    }

    package func directoryExists(at path: String) -> Bool {
        var isDirectory = ObjCBool(false)
        let exists = fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }

    package func recursivelyFindFiles(matchingExtension pathExtension: String, in directory: String) throws -> [String] {
        var matches: [String] = []
        let files = try contentsOfDirectory(atPath: directory)
        for file in files {
            let subpath = directory.appendingPathComponent(file)
            if file.pathExtension == pathExtension {
                matches.append(subpath)
            }
            if directoryExists(at: subpath) {
                matches += try recursivelyFindFiles(matchingExtension: pathExtension, in: subpath)
            }
        }
        return matches
    }
}

extension Sequence<UInt8> {
    package var asData: Data {
        Data(self)
    }
}

extension String {
    package init(initialCapacity: Int) {
        self = Self()
        self.reserveCapacity(initialCapacity)
    }
}

extension Array {
    package init(initialCapacity: Int) {
        self = Self()
        self.reserveCapacity(initialCapacity)
    }

    package mutating func sort<Value: Comparable>(on accessor: (Element) -> Value) {
        self.sort { lhs, rhs in
            accessor(lhs) < accessor(rhs)
        }
    }
}

extension Data {
    package init(contentsOf filePath: String) throws {
        try self.init(contentsOf: URL(filePath: filePath))
    }
}

extension Collection {
    package var only: Element? {
        (count == 1) ? first : nil
    }

    package func only(where predicate: (Element) -> Bool) -> Element? {
        var match: Element? = nil
        for candidate in self {
            if predicate(candidate) {
                if (match == nil) {
                    match = candidate
                } else {
                    return nil
                }
            }
        }
        return match
    }

    package func only<Value>(where accessor: (Element) -> Value, _ op: (Value, Value) -> Bool, _ operand: Value) -> Element? {
        only { candidate in
            op(accessor(candidate), operand)
        }
    }

    package func all<Value>(where accessor: (Element) -> Value, _ op: (Value, Value) -> Bool, _ operand: Value) -> [Element] {
        filter { candidate in
            op(accessor(candidate), operand)
        }
    }

    package func duplicateValues<Value: Hashable>(for accessor: (Element) throws -> Value) rethrows -> Set<Value> {
        var seen: Set<Value> = []
        var duplicates: Set<Value> = []
        for element in self {
            let value = try accessor(element)
            if !seen.insert(value).inserted {
                duplicates.insert(value)
            }
        }
        return duplicates
    }

    package var hasContent: Bool {
        !isEmpty
    }

    package func partition(atOnly subsequence: some Collection<Element>) -> (SubSequence, SubSequence)? where Element: Equatable {
        if let range = ranges(of: subsequence).only {
            return (self[..<range.lowerBound], self[range.upperBound...])
        } else {
            return nil
        }
    }

    package func partition(atFirst subsequence: some Collection<Element>) -> (SubSequence, SubSequence)? where Element: Equatable {
        if let range = firstRange(of: subsequence) {
            return (self[..<range.lowerBound], self[range.upperBound...])
        } else {
            return nil
        }
    }

    package func sorted<Value: Comparable>(on accessor: (Element) -> Value) -> [Element] {
        sorted { lhs, rhs in
            accessor(lhs) < accessor(rhs)
        }
    }

    package func anySatisfy(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
        try contains(where: predicate)
    }

    package func completeMap<R>(_ map: (Element) throws -> R?) rethrows -> [R]? {
        var result: [R] = Array(initialCapacity: count)
        for element in self {
            if let mapped = try map(element) {
                result.append(mapped)
            } else {
                return nil
            }
        }
        return result
    }

    package func sum() -> Element where Element: AdditiveArithmetic {
        var result: Element = .zero
        for element in self {
            result += element
        }
        return result
    }

    package func mean() -> Element? where Element: FloatingPoint {
        return hasContent ? sum() / Element(count) : nil
    }

    package func median() -> Element? where Element: FloatingPoint {
        if hasContent {
            let ordered = sorted()
            let midx = count / 2
            if ordered.count.isMultiple(of: 2) {
                let lhs = ordered[midx]
                let rhs = ordered[midx - 1]
                return (lhs + rhs) / 2
            } else {
                return ordered[midx]
            }
        } else {
            return nil
        }
    }
}

extension RangeReplaceableCollection {
    package mutating func extractFirst() -> Element? {
        return hasContent ? removeFirst() : nil
    }
}

extension BidirectionalCollection<String> {
    package func joined(by separator: String, finalSeparator: String) -> String {
        if count > 1, let last {
            return dropLast().joined(separator: separator) + finalSeparator + last
        } else {
            return joined(separator: separator)
        }
    }
}

extension Optional {
    package func unwrapOrAssertUnreachable() -> Wrapped {
        if let wrapped = self {
            return wrapped
        } else {
            preconditionFailure()
        }
    }

    package func unwrap(orThrow message: @autoclosure () -> String) throws -> Wrapped {
        if let wrapped = self {
            return wrapped
        } else {
            throw NSError(message())
        }
    }

    package func unwrap(orThrow error: @autoclosure () -> any Error) throws -> Wrapped {
        if let wrapped = self {
            return wrapped
        } else {
            throw error()
        }
    }
}

package struct TerminallyEnumerated<Base: Sequence>: Sequence {
    package typealias Element = (content: Base.Element, isStart: Bool, isEnd: Bool)

    private var base: Base
    fileprivate init(_ base: Base) {
        self.base = base
    }

    package struct Iterator: IteratorProtocol {
        private var base: Base.Iterator
        private var isStart = true
        private var lookahead: Base.Element?
        fileprivate init(base: Base.Iterator) {
            self.base = base
            self.lookahead = self.base.next()
        }

        package mutating func next() -> Element? {
            if let lookahead {
                var current = Element(lookahead, isStart: isStart, isEnd: false)
                self.lookahead = base.next()
                current.isEnd = (self.lookahead == nil)
                return current
            } else {
                return nil
            }
        }
    }

    package func makeIterator() -> Iterator {
        Iterator(base: base.makeIterator())
    }
}

extension Sequence {
    package func terminallyEnumerated() -> TerminallyEnumerated<Self> {
        TerminallyEnumerated(self)
    }
}

extension String {
    package var isSpearCase: Bool {
        (first?.isLowercaseASCII == true) && allSatisfy(\.isSpearCaseCharacter)
    }
}

extension BinaryInteger where Self: UnsignedInteger & FixedWidthInteger {
    package init(bit: some BinaryInteger) {
        self = 0 << bit
    }

    package func value(bit: some BinaryInteger) -> Bool {
        (self & (1 << bit) != 0) ? true : false
    }
}

package func require(_ expression: Bool, orThrow message: @autoclosure () -> String) throws {
    if !expression {
        throw NSError(message())
    }
}

package func require(_ expression: Bool, orThrow error: @autoclosure () -> any Error) throws {
    if !expression {
        throw error()
    }
}

extension String {
    package var smartQuoted: String {
        "“\(self)”"
    }

    package var quoted: String {
        "\"\(self)\""
    }

    package func mapComponentsSeparated<ResultElement>(byASCIICharacter character: UInt8, projection: (String) throws -> ResultElement) rethrows -> [ResultElement] {
        try utf8.split(separator: character, omittingEmptySubsequences: false).map { component in
            try projection(String(decoding: component, as: UTF8.self))
        }
    }
}

extension Character {
    package var smartQuoted: String {
        "“\(self)”"
    }

    fileprivate func selfIfEqual(_ counterpart: Character) -> Character? {
        (self == counterpart) ? self : nil
    }

    package var isLowercaseASCII: Bool {
        isASCII && isLowercase
    }

    package var isASCIIDigit: Bool {
        isASCII && isNumber
    }

    package var isSpearCaseCharacter: Bool {
        isLowercaseASCII || (self == "-")
    }
}


extension String {
    package func droppingRequiredPrefix(_ prefix: some StringProtocol) -> String? {
        if hasPrefix(prefix) {
            let start = index(startIndex, offsetBy: prefix.count)
            return String(self[start...])
        } else {
            return nil
        }
    }

    package func droppingPrefix(_ prefix: some StringProtocol) -> String {
        if hasPrefix(prefix) {
            let start = index(startIndex, offsetBy: prefix.count)
            return String(self[start...])
        } else {
            return self
        }
    }

    package func escaping(_ escaped: Character) -> String {
        var output = String()
        let escapeIndicator: Character = "\\"
        for character in self {
            if character == escaped {
                output.append(escapeIndicator)
                output.append(escaped)
            } else if character == escapeIndicator {
                output.append(escapeIndicator)
                output.append(escapeIndicator)
            } else {
                output.append(character)
            }
        }
        return output
    }

    package func unescaping(_ escapedCharacter: Character) throws -> String {
        switch unescapingUntilError(escapedCharacter: escapedCharacter) {
            case .complete(let result): return result
            case .unescapedSequence:
                throw NSError("Missing escape sequence for \("\(escapedCharacter)".smartQuoted) in \(self.smartQuoted)")
            case .invalidEscapeSequence(let character):
                throw NSError("Invalid escape sequence \("\\\(character)".smartQuoted) in \(self.smartQuoted)")
            case .unresolvedEscape:
                throw NSError("Invalid escape sequence in \(self.smartQuoted)")
        }
    }

    package enum UnescapingResult {
        case complete(String)
        case unescapedSequence(unescaped: String, remaining: String)
        case invalidEscapeSequence(Character)
        case unresolvedEscape
    }

    package func unescapingUntilError(escapedCharacter: Character) -> UnescapingResult {
        let escapeIndicator: Character = "\\"
        let hasEscaping = anySatisfy { candidate in
            (candidate == escapeIndicator) || (candidate == escapedCharacter)
        }
        if hasEscaping { // Even though we have to walk the bytes a second time, this saves time, and memory by letting the string internals do the walk, and by avoiding an extra allocation in the normal case were no unescaping is needed.
            var output = String(initialCapacity: count)
            var idx = startIndex
            while idx != endIndex {
                let character = self[idx]
                if (character == escapeIndicator) {
                    idx = self.index(after: idx)
                    if idx == endIndex {
                        return .unresolvedEscape
                    } else {
                        let nextCharacter = self[idx]
                        if nextCharacter == escapedCharacter {
                            output.append(escapedCharacter)
                        } else if nextCharacter == escapeIndicator {
                            output.append(escapeIndicator)
                        } else {
                            return .invalidEscapeSequence(nextCharacter)
                        }
                    }
                } else if (character == escapedCharacter) {
                    return .unescapedSequence(
                        unescaped: output,
                        remaining: String(self[idx...].dropFirst())
                    )
                } else {
                    output.append(character)
                }
                idx = self.index(after: idx)
            }
            return .complete(output)
        } else {
            return .complete(self)
        }
    }
}

extension Optional {
    @discardableResult
    package mutating func lazilyInitialize(with initializer: () throws -> Wrapped) rethrows -> Wrapped {
        if let wrapped = self {
            return wrapped
        } else {
            let value = try initializer()
            self = value
            return value
        }
    }
}

extension Sequence {
    package func compacted<Wrapped>() -> [Wrapped] where Element == Optional<Wrapped> {
        var compacted: [Wrapped] = []
        for element in self {
            if let element {
                compacted.append(element)
            }
        }
        return compacted
    }
}

extension Array {
    package init(repetitions: Int, of generator: () throws -> Element) rethrows {
        self.init(initialCapacity: repetitions)
        for _ in 0..<repetitions {
            try append(generator())
        }
    }
}
