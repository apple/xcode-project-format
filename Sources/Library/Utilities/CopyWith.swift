//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

package protocol CopyWith {
}

extension CopyWith {
    package func copy<Value>(with keyPath: WritableKeyPath<Self, Value>, _ value: Value) -> Self {
        var copy = self
        copy[keyPath: keyPath] = value
        return copy
    }

    package func copy<Value, Operand>(with keyPath: WritableKeyPath<Self, Value>, _ mutator: (inout Value, Operand) -> (), _ operand: Operand) -> Self {
        var value = self[keyPath: keyPath]
        mutator(&value, operand)
        return copy(with: keyPath, value)
    }
}
