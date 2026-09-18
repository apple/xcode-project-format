//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation

extension String.Encoding: XCJSON.Codable {
    fileprivate enum StringRepresentation: String, XCJSON.StringCodable {
        case ascii = "ascii"
        case nextstep = "nextstep"
        case japaneseEUC = "japanese-euc"
        case utf8 = "utf8"
        case isoLatin1 = "iso-latin-1"
        case symbol = "symbol"
        case nonLossyASCII = "non-lossy-ascii"
        case shiftJIS = "shift-jis"
        case isoLatin2 = "iso-latin-2"
        case unicode = "unicode"
        case windowsCP1251 = "windows-code-page-1251"
        case windowsCP1252 = "windows-code-page-1252"
        case windowsCP1253 = "windows-code-page-1253"
        case windowsCP1254 = "windows-code-page-1254"
        case windowsCP1250 = "windows-code-page-1250"
        case iso2022JP = "iso-2022-jp"
        case macOSRoman = "macos-roman"
        case utf16 = "utf16"
        case utf16BigEndian = "utf16-big-endian"
        case utf16LittleEndian = "utf16-little-endian"
        case utf32 = "utf32"
        case utf32BigEndian = "utf32-big-endian"
        case utf32LittleEndian = "utf32-little-endian"

        fileprivate var memoryRepresentation: String.Encoding {
            switch self {
                case .ascii: .ascii
                case .nextstep: .nextstep
                case .japaneseEUC: .japaneseEUC
                case .utf8: .utf8
                case .isoLatin1: .isoLatin1
                case .symbol: .symbol
                case .nonLossyASCII: .nonLossyASCII
                case .shiftJIS: .shiftJIS
                case .isoLatin2: .isoLatin2
                case .unicode: .unicode
                case .windowsCP1251: .windowsCP1251
                case .windowsCP1252: .windowsCP1252
                case .windowsCP1253: .windowsCP1253
                case .windowsCP1254: .windowsCP1254
                case .windowsCP1250: .windowsCP1250
                case .iso2022JP: .iso2022JP
                case .macOSRoman: .macOSRoman
                case .utf16: .utf16
                case .utf16BigEndian: .utf16BigEndian
                case .utf16LittleEndian: .utf16LittleEndian
                case .utf32: .utf32
                case .utf32BigEndian: .utf32BigEndian
                case .utf32LittleEndian: .utf32LittleEndian
            }
        }
    }

    private var stringRepresentation: StringRepresentation? {
        switch self {
            case .ascii: .ascii
            case .nextstep: .nextstep
            case .japaneseEUC: .japaneseEUC
            case .utf8: .utf8
            case .isoLatin1: .isoLatin1
            case .symbol: .symbol
            case .nonLossyASCII: .nonLossyASCII
            case .shiftJIS: .shiftJIS
            case .isoLatin2: .isoLatin2
            case .unicode: .unicode
            case .windowsCP1251: .windowsCP1251
            case .windowsCP1252: .windowsCP1252
            case .windowsCP1253: .windowsCP1253
            case .windowsCP1254: .windowsCP1254
            case .windowsCP1250: .windowsCP1250
            case .iso2022JP: .iso2022JP
            case .macOSRoman: .macOSRoman
            case .utf16: .utf16
            case .utf16BigEndian: .utf16BigEndian
            case .utf16LittleEndian: .utf16LittleEndian
            case .utf32: .utf32
            case .utf32BigEndian: .utf32BigEndian
            case .utf32LittleEndian: .utf32LittleEndian
            default: nil
        }
    }

    package func encode(with coder: XCJSON.Encoder) throws {
        if let stringRepresentation {
            try stringRepresentation.encode(with: coder)
        } else {
            let value = try Int(exactly: rawValue).unwrap(orThrow: "Unsupported text encoding \(rawValue)")
            try value.encode(with: coder)
        }
    }

    package init(with coder: XCJSON.Decoder) throws {
        if coder.currentNodeType == .string {
            self = try StringRepresentation(with: coder).memoryRepresentation
        } else {
            let value = try Int(with: coder)
            let rawValue = try UInt(exactly: value).unwrap(orThrow: "Invalid text encoding \(value)")
            self = Self(rawValue: rawValue)
        }
    }
}
