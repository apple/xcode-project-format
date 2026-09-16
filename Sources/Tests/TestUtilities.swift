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

func expectRoundTripEqual<Value: XCJSONCodable & Equatable>(_ encoded: Value) {
    #expect(throws: Never.self) {
        let data = try XCJSON.Encoder.data(for: encoded, options: XCJSON.EncodingOptions.defaultOptions)
        let decoded: Value = try XCJSON.Decoder.decode(data: data)
        #expect(encoded == decoded)
    }
}

extension Array {
    /// Returns the permutations of the receiver.
    /// Caution! there are O(n!) permutations of a collection, which can go off the rails quickly. An array with 10 elements has 3,628,800 permutations.
    /// It's really only reasonable to call this method if you have an upper bound on the array size and know it's single digits.
    func enumeratePermutationsInFactorialTime(_ body: (_ permutation: Self) -> ()) {
        var permutation = self
        func shuffle(decidedLength: Int) {
            if decidedLength == count {
                body(permutation)
            } else {
                for index in decidedLength..<permutation.count {
                    permutation.swapAt(decidedLength, index)
                    shuffle(decidedLength: decidedLength + 1)
                    permutation.swapAt(decidedLength, index)
                }
            }
        }
        shuffle(decidedLength: 0)
    }

    func enumerateAllSubsetsInExponentialTime(_ body: (_ permutation: Self) -> ()) {
        var subset = Array(initialCapacity: count)
        body(subset)
        func enumerate(position: Int) {
            if position != count {
                subset.append(self[position])
                body(subset)
                enumerate(position: position + 1)
                subset.removeLast()
                enumerate(position: position + 1)
            }
        }
        enumerate(position: 0)
    }
}

extension Array<String> {
    func allSubsetPermutationJoinings() -> [String] {
        var result: [String] = []
        enumerateAllSubsetPermutationJoinings { string in
            result.append(string)
        }
        return result
    }

    func enumerateAllSubsetPermutationJoinings(_ body: (String) -> ()) {
        enumerateAllSubsetsInExponentialTime { subset in
            subset.enumeratePermutationsInFactorialTime { permutation in
                body(permutation.joined())
            }
        }
    }
}

// Consume a value so that its creation isn't optimized away, intended for performance tests.
@_optimize(none) func blackhole<V>(_ value: V) {

}

func measureDuration(of body: () throws -> ()) rethrows -> TimeInterval {
    let start = ProcessInfo.processInfo.systemUptime
    try body()
    let end = ProcessInfo.processInfo.systemUptime
    return end - start
}
