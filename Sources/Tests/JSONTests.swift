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

struct Task: XCJSON.Encodable, Equatable {
    var identifier: Int
    var priority: Double
    var component: String?
    var optional: Bool
    var title: String
    var subtasks: [Task]

    func encode(with coder: XCJSON.Encoder) throws {
        let container = coder.openKeyedContainer()
        try container.encode(identifier, for: "identifier", unconditionally: .affirmative)
        try container.encode(priority, for: "priority", unconditionally: .affirmative)
        try container.encode(component, for: "component", defaultValue: nil)
        try container.encode(optional, for: "optional", defaultValue: false)
        try container.encode(title, for: "title", unconditionally: .affirmative)
        try container.encode(subtasks, for: "subtasks", defaultValue: [])
    }
}

typealias XCJSONEncodable = XCJSON.Encodable
typealias XCJSONDecodable = XCJSON.Decodable
typealias XCJSONCodable = XCJSONEncodable & XCJSONDecodable

struct XCJSONEncoderTests {
    func expectEncoding<Value: XCJSONEncodable>(_ value: Value, _ expected: XCJSON.Value) {
        #expect(throws: Never.self) {
            let encoded = try XCJSON.Encoder.json(for: value)
            #expect(encoded == expected)
        }
    }

    @Test func testNulls() throws {
        expectEncoding(Optional<String>.none, .null)
    }

    @Test func testPrimitives() throws {
        expectEncoding(false, false)
        expectEncoding(true, true)
        expectEncoding(0, 0)
        expectEncoding(1, 1)
        expectEncoding(-1, -1)
        expectEncoding(0.0, 0.0)
        expectEncoding(1.5, 1.5)
        expectEncoding(-1.5, -1.5)
        expectEncoding("", "")
        expectEncoding("A", "A")
    }

    @Test func testArrays() throws {
        expectEncoding([false], [false])
        expectEncoding([false, true], [false, true])
    }


    @Test func testDictionaries() throws {
        expectEncoding(["off": false], ["off": false])
        expectEncoding(["off": false, "on": true], ["off": false, "on": true])
    }

    @Test func testObjects() throws {
        let makeThemAllPass = Task(identifier: 1234, priority: 1.0, optional: false, title: "Make sure they all pass", subtasks: [])
        let addComments = Task(identifier: 12345, priority: 4.5, component: "Documentation | X", optional: true, title: "Add lots of comments", subtasks: [])
        let umbrella = Task(identifier: 123, priority: 1.25, optional: false, title: "Write Encoder Tests", subtasks: [
            makeThemAllPass,
            addComments,
        ])
        let makeThemAllPassJSON: XCJSON.Value = [
            "identifier": 1234,
            "priority": 1.0,
            "title": "Make sure they all pass",
        ]
        let addCommentsJSON: XCJSON.Value = [
            "identifier": 12345,
            "priority": 4.5,
            "component": "Documentation | X",
            "optional": true,
            "title": "Add lots of comments",
        ]
        expectEncoding(makeThemAllPass, makeThemAllPassJSON)
        expectEncoding(addComments, addCommentsJSON)
        expectEncoding(umbrella, [
            "identifier": 123,
            "priority": 1.25,
            "title": "Write Encoder Tests",
            "subtasks": [
                makeThemAllPassJSON,
                addCommentsJSON,
            ],
        ])
    }
}

struct XCJSONRoundTrippingTests {

    @Test func testRoundTripping() throws {
        expectRoundTripEqual(String?.none)

        expectRoundTripEqual(false)
        expectRoundTripEqual(true)
        expectRoundTripEqual(0)
        expectRoundTripEqual(+1)
        expectRoundTripEqual(-1)
        expectRoundTripEqual(+1.5)
        expectRoundTripEqual(-1.5)
        expectRoundTripEqual("")
        expectRoundTripEqual("String")

        expectRoundTripEqual([false])
        expectRoundTripEqual([true])
        expectRoundTripEqual([0])
        expectRoundTripEqual([+1])
        expectRoundTripEqual([-1])
        expectRoundTripEqual([+1.5])
        expectRoundTripEqual([-1.5])
        expectRoundTripEqual([""])
        expectRoundTripEqual(["String"])

        expectRoundTripEqual(["field": false])
        expectRoundTripEqual(["field": true])
        expectRoundTripEqual(["field": 0])
        expectRoundTripEqual(["field": +1])
        expectRoundTripEqual(["field": -1])
        expectRoundTripEqual(["field": +1.5])
        expectRoundTripEqual(["field": -1.5])
        expectRoundTripEqual(["field": ""])
        expectRoundTripEqual(["field": "String"])
    }

    @Test func testAllAsciiCharacterStrings() throws {
        for ascii in 0..<UInt8(127) {
            expectRoundTripEqual(String(format: "%c", ascii))
        }
    }

    func expect(_ value: XCJSON.Value, encodesTo expectedText: String, densities: [XCJSON.AbsolutePath: XCJSON.PrintingDensity] = [:]) {
        let text = value.textRepresentation(options: .defaultOptions, densities: densities)
        #expect(text == expectedText)
    }

    func expect(value: XCJSON.Value, encodesTo lines: [String], densities: [XCJSON.AbsolutePath: XCJSON.PrintingDensity] = [:]) {
        expect(value, encodesTo: lines.stringFromLines(), densities: densities)
    }

    func expect<Value: XCJSONCodable & Equatable>(_ original: Value, roundTripsAndEncodesTo expectedText: String, options: XCJSON.EncodingOptions = .defaultOptions) {
        #expect(throws: Never.self) {
            let text = try XCJSON.Encoder.text(for: original, options: options)
            #expect(text == expectedText)
            do {
                let decoded: Value = try XCJSON.Decoder.decode(data: Data(text.utf8))
                print(decoded)
                #expect(original == decoded)
            } catch {
                Issue.record("Decode failed: \(error)")
            }
        }
    }

    func expect<Value: XCJSONCodable & Equatable>(_ original: Value, roundTripsAndEncodesTo lines: [String]) {
        expect(original, roundTripsAndEncodesTo: lines.stringFromLines())
    }

    @Test func filePathEncoding() {
        typealias FilePath = XCSchema.FilePath
        func expect(_ base: FilePath.Base, _ path: String, roundTripsAndEncodesTo expectedText: String) {
            do {
                let original = try FilePath(base: base, path: path)
                #expect(original.stringRepresentation == expectedText)
                expectRoundTripEqual(original)
            } catch {
                Issue.record(error)
            }
        }

        expect(.group, "File.swift", roundTripsAndEncodesTo: "File.swift")
        expect(.absolute, "/File.swift", roundTripsAndEncodesTo: "/File.swift")
        expect(.absolute, "~/project/File.swift", roundTripsAndEncodesTo: "~/project/File.swift")
        expect(.absolute, "~", roundTripsAndEncodesTo: "~")
        expect(.absolute, "~user/File.swift", roundTripsAndEncodesTo: "~user/File.swift")
        expect(.project, "File.swift", roundTripsAndEncodesTo: "<PROJECT>/File.swift")
        expect(.sdk, "File.swift", roundTripsAndEncodesTo: "<SDK>/File.swift")
        expect(.developer, "File.swift", roundTripsAndEncodesTo: "<DEVELOPER>/File.swift")
        expect(.buildProducts, "File.swift", roundTripsAndEncodesTo: "<PRODUCTS>/File.swift")
        expect(.sourceRoot("SHARED"), "File.swift", roundTripsAndEncodesTo: "<USER:SHARED>/File.swift")

        expect(.group, "<", roundTripsAndEncodesTo: "\\<")
        expect(.group, "\\<>/Component", roundTripsAndEncodesTo: "\\\\\\<>/Component")
        expect(.group, "\\", roundTripsAndEncodesTo: "\\\\")
        expect(.group, "<Readme.md", roundTripsAndEncodesTo: "\\<Readme.md")
        expect(.group, "\\Readme.md", roundTripsAndEncodesTo: "\\\\Readme.md")
        expect(.group, "./Readme.md", roundTripsAndEncodesTo: "./Readme.md")
        expect(.sourceRoot("custom"), "Readme.md", roundTripsAndEncodesTo: "<USER:custom>/Readme.md")
        expect(.sourceRoot("<"), "Readme.md", roundTripsAndEncodesTo: "<USER:<>/Readme.md")
        expect(.sourceRoot(">"), "Readme.md", roundTripsAndEncodesTo: "<USER:\\>>/Readme.md")
        expect(.sourceRoot("$()"), "Readme.md", roundTripsAndEncodesTo: "<USER:$()>/Readme.md")
    }

    @Test func testArrays() throws {
        expect(value: .array([
        ]), encodesTo: [
            "[",
            "]",
        ])
        expect(value: .array([
            .integer(1),
        ]), encodesTo: [
            "[",
            "  1,",
            "]",
        ])

        expect(value: .array([
        ]), encodesTo: [
            "[]",
        ], densities: [.root : .compact])
        expect(value: .array([
            .integer(1),
        ]), encodesTo: [
            "[ 1 ]",
        ], densities: [.root : .compact])
    }

    @Test func testDictionaries() throws {
        expect(value: .object(XCJSON.Object([
        ])), encodesTo: [
            "{",
            "}",
        ])
        expect(value: .object(XCJSON.Object([
            .field(XCJSON.Field("key", "value")),
        ])), encodesTo: [
            "{",
            "  \"key\": \"value\",",
            "}",
        ])

        expect(value: .object(XCJSON.Object([
        ])), encodesTo: [
            "{}",
        ], densities: [.root : .compact])

        expect(value: .object(XCJSON.Object([
            .field(XCJSON.Field("key", "value")),
        ])), encodesTo: [
            "{ \"key\": \"value\" }",
        ], densities: [.root : .compact])
    }

    @Test func testComments() throws {
        try expect(value: .array([
            .integer(1),
            .comment(style: .line, content: "Empty"),
        ]), encodesTo: [
            "[",
            "  1,",
            "  // Empty",
            "]",
        ])

        try expect(value: .array([
            .string("a string"),
            .comment(style: .line, content: "Trailing"),
        ]), encodesTo: [
            "[",
            "  \"a string\",",
            "  // Trailing",
            "]",
        ])

        try expect(value: .array([
            .comment(style: .line, content: "Leading"),
            .string("a string"),
        ]), encodesTo: [
            "[",
            "  // Leading",
            "  \"a string\",",
            "]",
        ])

        try expect(value: .array([
            .comment(style: .block, content: "Block"),
        ]), encodesTo: [
            "[",
            "  /* Block */",
            "]",
        ])
        try expect(value: .array([
            .comment(style: .block, content: "\nTwo Line\nOutdented Block\n"),
        ]), encodesTo: [
            "[",
            "  /*",
            "  Two Line",
            "  Outdented Block",
            "  */",
            "]",
        ])
        try expect(value: .array([
            .comment(style: .block, content: "Two Line\nBlock"),
        ]), encodesTo: [
            "[",
            "  /* Two Line",
            "     Block */",
            "]",
        ])
    }

    @Test func testMarketingVersionSpellings() throws {
        func test(_ major: Int, _ minor: Int, _ update: Int, expecting encoding: String) {
            #expect(XCSchema.MarketingVersion(major: major, minor: minor, update: update).encodableStringRepresentation == encoding)
        }
        test(0, 0, 0, expecting: "0.0")
        test(0, 0, 1, expecting: "0.0.1")
        test(1, 0, 0, expecting: "1.0")
        test(1, 2, 0, expecting: "1.2")
        test(1, 0, 3, expecting: "1.0.3")
    }

    @Test func testUncompacting() throws {
        expect(value: .array([
            .string("Line1\nLine2"),
        ]), encodesTo: [
            "[ \"Line1\\nLine2\" ]",
        ], densities: [.root : .compact])

        expect(value: .object(XCJSON.Object([
            .field("line1\nline2", "value")
        ])), encodesTo: [
            "{",
            "  \"line1\\nline2\": \"value\",",
            "}",
        ])

        try expect(value: .array([
            .comment(style: .line, content: "Empty"),
        ]), encodesTo: [
            "[",
            "  // Empty",
            "]",
        ], densities: [.root : .compact])

        try expect(value: .array([
            .comment(style: .block, content: "Empty"),
        ]), encodesTo: [
            "[ /* Empty */ ]",
        ], densities: [.root : .compact])

        try expect(value: .array([
            .comment(style: .block, content: "Line1\nLine2"),
        ]), encodesTo: [
            "[",
            "  /* Line1",
            "     Line2 */",
            "]",
        ], densities: [.root : .compact])

        try expect(value: .array([
            .comment(style: .block, content: "Empty"),
        ]), encodesTo: [
            "[ /* Empty */ ]",
        ], densities: [.root : .compact])

        try expect(value: .array([
            .comment(style: .block, content: "Empty"),
        ]), encodesTo: [
            "[ /* Empty */ ]",
        ], densities: [.root : .compact])
    }


    @Test func testArrayWhitespace() throws {
        expect(value: .array([
            .object(XCJSON.Object([
                .field("key", "value")
            ])),
        ]), encodesTo: [
            "[",
            "  {",
            "    \"key\": \"value\",",
            "  },",
            "]",
        ])

        expect(value: .array([
            .object(XCJSON.Object([
                .field("key", "value")
            ])),
            .object(XCJSON.Object([
                .field("key", "value2")
            ])),
        ]), encodesTo: [
            "[",
            "  {",
            "    \"key\": \"value\",",
            "  }, {",
            "    \"key\": \"value2\",",
            "  },",
            "]",
        ])

        expect(value: .array([
            .object(XCJSON.Object([
                .field("key", "value")
            ])),
            .integer(3),
            .object(XCJSON.Object([
                .field("key", "value2")
            ])),
        ]), encodesTo: [
            "[",
            "  {",
            "    \"key\": \"value\",",
            "  },",
            "  3,",
            "  {",
            "    \"key\": \"value2\",",
            "  },",
            "]",
        ])

        expect(value: .array([
            .object(XCJSON.Object([
                .field("key", "value")
            ])),
            .integer(3),
        ]), encodesTo: [
            "[",
            "  {",
            "    \"key\": \"value\",",
            "  },",
            "  3,",
            "]",
        ])



        expect(value: .array([
            .object(XCJSON.Object([
                .field("key", "value")
            ])),
        ]), encodesTo: [
            "[",
            "  { \"key\": \"value\" },",
            "]",
        ], densities: [.node(.init(parent: .root, component: .index(0))) : .compact])

        expect(value: .array([
            .object(XCJSON.Object([
                .field("key", "value"),
            ])),
            .object(XCJSON.Object([
                .field("key", "value2"),
            ])),
        ]), encodesTo: [
            "[",
            "  { \"key\": \"value\" },",
            "  { \"key\": \"value2\" },",
            "]",
        ], densities: [
            .node(.init(parent: .root, component: .index(0))) : .compact,
            .node(.init(parent: .root, component: .index(1))) : .compact,
        ])

        expect(value: .array([
            .object(XCJSON.Object([
                .field("key", "value"),
            ])),
            .integer(3),
            .object(XCJSON.Object([
                .field("key", "value2"),
            ])),
        ]), encodesTo: [
            "[",
            "  { \"key\": \"value\" },",
            "  3,",
            "  { \"key\": \"value2\" },",
            "]",
        ], densities: [
            .node(.init(parent: .root, component: .index(0))) : .compact,
            .node(.init(parent: .root, component: .index(2))) : .compact,
        ])
    }


    @Test func testIntegerExtremes() throws {
        func test<I: FixedWidthInteger & XCJSONCodable>(_ integerType: I.Type) {
            expectRoundTripEqual(integerType.min)
            expectRoundTripEqual(integerType.zero)
            expectRoundTripEqual(integerType.max)
        }

        test(Int.self)
        //test(UInt.self)
    }

    @Test func testFloatingPointExtremes() throws {
        func test<F: BinaryFloatingPoint & XCJSONCodable>(_ floatType: F.Type) {
            expectRoundTripEqual(floatType.greatestFiniteMagnitude)
            expectRoundTripEqual(floatType.pi)
            expectRoundTripEqual(floatType.ulpOfOne)

            // JSONSerialization doesn't seem to accept these.
            // expectRoundTripEqual(floatType.infinity)
            // expectRoundTripEqual(floatType.nan)
        }

        test(Double.self)
        test(Float.self)
    }
}

extension Array where Element: StringProtocol {
    func stringFromLines() -> String {
        joined(separator: "\n") + "\n"
    }
}
