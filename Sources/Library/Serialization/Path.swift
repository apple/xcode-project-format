//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension XCJSON {
    package enum AbsolutePath: Hashable, CustomStringConvertible {
        package init() {
            self = .root
        }

        package init(parent: AbsolutePath, component: PathComponent) {
            self = .node(Node(parent: parent, component: component))
        }

        case root
        indirect case node(Node)

        package struct Node: Hashable {
            var parent: AbsolutePath
            var component: PathComponent

            package init(parent: AbsolutePath, component: PathComponent) {
                self.parent = parent
                self.component = component
            }
        }

        package var node: Node? {
            switch self {
                case .root: nil
                case let .node(node): node
            }
        }

        package var isRoot: Bool {
            node == nil
        }

        package var parent: AbsolutePath? {
            node?.parent
        }

        package var component: PathComponent? {
            node?.component
        }

        package var components: [PathComponent] {
            var next = node
            var components: [PathComponent] = []
            while let current = next {
                components.append(current.component)
                next = current.parent.node
            }
            components.reverse()
            return components
        }

        package var description: String {
            components.map(\.description).joined()
        }

        package func appending(_ component: PathComponent) -> AbsolutePath {
            .node(Node(parent: self, component: component))
        }

        package func appending(_ index: Int) -> AbsolutePath {
            appending(.index(index))
        }

        package func appending(_ key: String) -> AbsolutePath {
            appending(.key(key))
        }

    }

    package enum PathComponent: Hashable, CustomStringConvertible {
        case key(String)
        case index(Int)

        package var description: String {
            switch self {
                case let .key(key): return "/" + key
                case let .index(index): return "[\(index)]"
            }
        }
    }
}
