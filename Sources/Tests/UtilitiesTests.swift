//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import XcodeProjectFormat
import Foundation
import Testing

struct UtilityTests {
    @Test func testEscaping() throws {
        func test(_ original: String, roundTripsAndEscapesTo expectedEncoding: String) throws {
            let actualEncoding = original.escaping("<")
            #expect(actualEncoding == expectedEncoding)
            let decoding = try actualEncoding.unescaping("<")
            #expect(original == decoding)
        }
        try test("", roundTripsAndEscapesTo: "")
        try test("a", roundTripsAndEscapesTo: "a")
        try test("<", roundTripsAndEscapesTo: "\\<")
        try test("\\", roundTripsAndEscapesTo: "\\\\")
        try test("<<", roundTripsAndEscapesTo: "\\<\\<")

        #expect(throws: NSError.self) {
            try "\\<".unescaping("j")
        }
        #expect(throws: NSError.self) {
            try "\\".unescaping("j")
        }
    }

    @Test func testMapComponentsSeparated() {
        func test(_ string: String) {
            let actual = string.mapComponentsSeparated(byASCIICharacter: UInt8(ascii: "/"), projection: { $0 })
            let expected = string.components(separatedBy: "/")
            #expect(actual == expected)
        }
        test("")
        test("/")
        test("A/")
        test("/A")
        test("A/B")
        test("//")

        let candidateComponents = [
            "a",
            "b",
            "/",
            "/",
            "😅",
            "试",
        ]

        candidateComponents.enumerateAllSubsetPermutationJoinings { hardString in
            test(hardString)
        }

    }
}
