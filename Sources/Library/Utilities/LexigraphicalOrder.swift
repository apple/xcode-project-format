//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

package struct LexicographicalOrder2<T0: Comparable, T1: Comparable>: Comparable {
    package var content: (T0, T1)
    package  init(content: (T0, T1)) {
        self.content = content
    }

    package  init(_ t0: T0, _ t1: T1) {
        self.content = (t0, t1)
    }

    package static func ==(_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.content == rhs.content
    }

    package static func <(_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.content < rhs.content
    }
}

package struct LexicographicalOrder3<T0: Comparable, T1: Comparable, T2: Comparable>: Comparable {
    package var content: (T0, T1, T2)
    package init(content: (T0, T1, T2)) {
        self.content = content
    }

    package  init(_ t0: T0, _ t1: T1, _ t2: T2) {
        self.content = (t0, t1, t2)
    }

    package static func ==(_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.content == rhs.content
    }

    package static func <(_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.content < rhs.content
    }
}

package struct LexicographicalOrder4<T0: Comparable, T1: Comparable, T2: Comparable, T3: Comparable>: Comparable {
    package var content: (T0, T1, T2, T3)
    package  init(content: (T0, T1, T2, T3)) {
        self.content = content
    }

    package  init(_ t0: T0, _ t1: T1, _ t2: T2, _ t3: T3) {
        self.content = (t0, t1, t2, t3)
    }

    package static func ==(_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.content == rhs.content
    }

    package static func <(_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.content < rhs.content
    }
}

package struct LexicographicalOrder5<T0: Comparable, T1: Comparable, T2: Comparable, T3: Comparable, T4: Comparable>: Comparable {
    package var content: (T0, T1, T2, T3, T4)

    package  init(content: (T0, T1, T2, T3, T4)) {
        self.content = content
    }

    package  init(_ t0: T0, _ t1: T1, _ t2: T2, _ t3: T3, _ t4: T4) {
        self.content = (t0, t1, t2, t3, t4)
    }

    package static func ==(_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.content == rhs.content
    }

    package static func <(_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.content < rhs.content
    }
}

package func LexicographicalOrder<T0: Comparable, T1: Comparable>(_ t0: T0, _ t1: T1) -> LexicographicalOrder2<T0, T1> {
    LexicographicalOrder2(t0, t1)
}

package func LexicographicalOrder<T0: Comparable, T1: Comparable, T2: Comparable>(_ t0: T0, _ t1: T1, _ t2: T2) -> LexicographicalOrder3<T0, T1, T2> {
    LexicographicalOrder3(t0, t1, t2)
}

package func LexicographicalOrder<T0: Comparable, T1: Comparable, T2: Comparable, T3: Comparable>(_ t0: T0, _ t1: T1, _ t2: T2, _ t3: T3) -> LexicographicalOrder4<T0, T1, T2, T3> {
    LexicographicalOrder4(t0, t1, t2, t3)
}

package func LexicographicalOrder<T0: Comparable, T1: Comparable, T2: Comparable, T3: Comparable, T4: Comparable>(_ t0: T0, _ t1: T1, _ t2: T2, _ t3: T3, _ t4: T4) -> LexicographicalOrder5<T0, T1, T2, T3, T4> {
    LexicographicalOrder5(t0, t1, t2, t3, t4)
}
