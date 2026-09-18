# xcode-project-format

`xcode-project-format` is a Swift library for reading, writing, and manipulating Xcode's JSON-based `project.xcproj` format. It models the format as a rich set of value types nested under a single namespace, `XCSchema`, so consumers get precise, typed access to a project's structure instead of hand-parsing JSON.

The goal is to give the ecosystem a shared, accurate model of the Xcode project format — so tools like generators, linters, verifiers, and validators don't each have to reverse-engineer the format from scratch.

The package also ships `xcprojformatter`, a small CLI tool built on the library.

## Getting started

### Requirements

- Swift 6.1 or later
- macOS 14 or later (the library also builds on non-Darwin platforms; see [Package.swift](Package.swift))

### Installation

Add the package as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/apple/xcode-project-format/", from: "0.1.0")
]
```

### Usage

```swift
import XcodeProjectFormat

func listTargets(in projectURL: URL) throws {
    let projectData = try Data(contentsOf: projectURL)
    let project = try XCSchema.Project(jsonRepresentation: projectData)
    for target in project.targets {
        print(target.name)
    }
}
```

You'll find types for folders, file references, groups, targets, build phases, build rules, and the rest of the Xcode project model within this package.

## Documentation

The [project documentation](https://swiftpackageindex.com/apple/xcode-project-format/main/documentation/xcodeprojectformat) is available at [Swift Package Index](https://swiftpackageindex.com/).

To preview it locally:

```bash
swift package add-dependency https://github.com/swiftlang/swift-docc-plugin --from 1.5.0
swift package --disable-sandbox preview-documentation
```

## Contributing

We welcome contributions within a defined scope. See [CONTRIBUTING.md](CONTRIBUTING.md) for what we accept, what's out of scope for now, and how to get started.

## Support

- [GitHub Issues](../../issues) — bug reports, feature requests, and questions

## License

Licensed under the [Apache License 2.0](LICENSE.txt).
