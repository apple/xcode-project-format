# Package Layout

The XcodeProjectFormat package is composed of 3 primary targets:

* XcodeProjectFormat
* XcodeProjectTool
* XcodeProjectFormatTests

- - -

## XcodeProjectFormat

The primary library target is `XcodeProjectFormat`, which is divided into two components: `XCSchema` and `XCJSON`.

`XCSchema` contains all of the value types that are used to encode and decode the `project.xcproj` file format.

`XCJSON` implements a custom JSON5 encoder that preserves key order and allows white-space customization.

- - -

## XcodeProjectTool

A command-line tool to verify and canonically reformat `project.xcproj` files.

- - -

## XcodeProjectFormatTests

Unit tests for the `XcodeProjectFormat` library. Many tests focus on round-tripping serializable subgraphs of the project model and asserting equality after transcoding.
