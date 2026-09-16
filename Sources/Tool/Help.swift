//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

func helpText() -> String {
"""
The xcprojformatter tool pretty prints 'project.xcproj' Xcode project files in their canonical format.

Usage:

    xcprojformatter [[--input] input-project] [--output output-project]
    xcprojformatter --help

Arguments:
    --input     The path to an Xcode project. It can refer to the outer ".xcodeproj" directory, or the inner "project.xcproj" file.
    --output    The path to an Xcode project. It can refer to the outer ".xcodeproj" directory, or the inner "project.xcproj" file.
    --update    A short hand for passing --input and --output with the same value.

Example Invocations:

    # Updates `Project.xcodeproj/project.xcproj` in place
    xcprojformatter --update Project.xcodeproj

    # Reads a project file on standard input, pretty prints it, and writes it to standard output.
    xcprojformatter

    # Reads "project.xcodeproj/project.xcproj", pretty prints it, and writes it to standard output.
    xcprojformatter project.xcodeproj

    # Reads "project.xcodeproj/project.xcproj", pretty prints it, and writes it to standard output.
    xcprojformatter --input project.xcodeproj

    # Reads "input.xcodeproj/project.xcproj", pretty prints it, and writes it to "output.xcodeproj/project.xcproj".
    xcprojformatter --input input.xcodeproj --output output.xcodeproj
"""
}
