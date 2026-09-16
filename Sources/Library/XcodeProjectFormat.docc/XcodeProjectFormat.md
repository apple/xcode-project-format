# ``XcodeProjectFormat``

A library to decode, encode and manipulate Xcode's `project.xcproj` JSON project files.

## Overview

This package's library implements Xcode's `project.xcproj` file encoding and decoding, and can be used to build Xcode project manipulation tools like generators, linters, and validators.

The package contains a rich set of value types nested within `XCSchema` precisely modeling the Xcode Project format.

Here's a quick example of decoding a project, and listing its targets:

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

## Topics

### Getting Started

- <doc:package-layout>
- <doc:schema-overview>
- <doc:file-format-goals>

### Project Schema

- ``XCSchema``
