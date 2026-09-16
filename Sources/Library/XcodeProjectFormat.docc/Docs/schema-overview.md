# Schema Overview

This document describes the major components of the Xcode project schema, and how they fit together.

## Projects

The root object of a `project.xcproj` file is the `Project`.

Projects are composed of:

* File Tree
* Targets
* Build Configurations
* Build Settings
* External Dependencies

- - -

## File Tree

The file tree represents the groups, files, and folders in a project. Xcode shows the project's file tree in the project navigator.

A file can be in zero, one, or many targets, so the file's membership in a project is about the file itself, not if and how it's processed by the build. Properties on a file are its path, what the path is relative to, an explicit overriding file type, etc.

Xcode uses the term "reference" to refer to any of the nodes in the file tree. The reference subtypes are:

* FileReference
* Group
* Folder
* Variant Group
* Version Group

References represent file system objects, and their primary attributes are a path variable and a base to resolve the path against. The most common configuration is a relative path from the parent item. But paths can be absolute, relative to the project, build directory, SDK, etc.

### File Reference

A file reference is an explicit reference to a file. File references can be members of targets and participate in the build, and can carry configuration attributes like a file type override, explicit text encoding, etc.

### Group

A group in Xcode is a virtual grouping construct, traditionally represented with a gray folder icon in Xcode. By convention, most projects have a group tree that exactly aligns with their file system layout, but this is by convention only. Groups are just an arbitrary collection of other reference objects without any uniqueness or completeness constraints on how they map to the file system. A group is excellent for collocating objects in Xcode that aren't adjacent in the file system, for bringing a curated view of the file system into the project, or creating hierarchy in Xcode where the file system layout is constrained to be flat by some external requirement.

Groups do not participate in targets, they only organize file references.

### Folders

A folder is an alternative to a group, traditionally represented with a blue folder icon in Xcode. A folder completely represents a file system tree in Xcode. It creates subfolders and file references for all of the nested content. The content is discovered at project load time and is kept synchronized.

A key strength of the folder is that it doesn't encode the file system hierarchy into the Xcode project, meaning that typical file insertions into the project don't modify the project file.

Unlike groups, folders are members of targets. As a folder discovers file system content, the content is implicitly added to the folder's targets. So a discovered PNG would be copied as a resource, while a Swift file would participate in the compiled sources phase.

The user is free to fully customize the target membership of the discovered files in Xcode. For example, by choosing to exclude some files from the build or by adding some files to extra targets. Folders use "exception sets" to represent files that don't use the implied targets. In addition to inclusion and exclusion, exception sets also represent customized build properties, like a header file being public in an Objective-C framework.

### Variant Groups

A variant group represents a localized file and collects per-language representations from the separate `lproj` folders into a single group. In a way, it transposes the group hierarchy from the file system representation.

If the file system layout looked like:
```
Resources
    en.lproj/
        Background.png
        Text.strings
    es.lproj/
        Background.png
        Text.strings
```

Then the variant groups would create a group tree like:

```
Resources
    Background.png/
        en
        es
    Text.strings/
        en
        es
```

### Version Groups

A version group encodes a group of versioned files and their primary version. This is currently only used for versioned Core Data models.

### Opaque Folders

Xcode offers a type of opaque folder reference where the content of the folder doesn't participate individually in the build graph. Instead, the whole folder flows through the build as a unit, with build rules matching against the entire folder as a single entity. This usually results in the folder matching the copy rule and being copied to the target's build product verbatim. It is great for including things like a tree of html, js and css files.

These are very different from the Folder described above, even though they look very similar in the Xcode UI.

Opaque folders are represented by file references that happen to refer to a folder, and hence it is the single file reference with no children that participates in the build graph.

### Project References

Xcode projects can refer to other Xcode projects to create cross-project dependencies. These are represented by a file reference that refers to the counterpart `.xcodeproj` file wrapper. These file references aren't typically in a target, but Xcode can see into the content of the linked project and allows the referencing project to use the products of the referenced project in its build. This is often used to keep frameworks in one project, while several other projects use and build those frameworks by reference.

- - -

## Targets

The project.xcproj format supports 3 target types:

* Target
* Aggregate Target
* External Target

An aggregate target is just a group of targets, and an external target is just an external build command.

The plain target type is the primary one that produces a product.

Targets are composed of:

* Build Settings
* Build Configuration Files
* Build Phases
* Build Rules

### Build Settings

Build settings are key-value pairs in the Xcode project format. The key is always a string, and the value is either a string or an array of strings. Xcode's build settings can be conditional on configuration, SDK, and processor architecture with support for wildcard matching. `XcodeProjectFormat` does not offer APIs to process these values in a format richer than their raw string representation.

Build settings have precedence levels, and build settings at the target level are higher precedence than build settings at the project level.

### Build Configuration Files

A target can refer to one xcconfig file per build configuration (Debug, Release, etc.)

### Build Phases

A build phase represents a task or collection of files to process during the build. Build phases can carry attributes relevant to all of the member files.

The most common build phases are:

* Compile Sources
* Copy Headers
* Copy Resources
* Copy Files
* Shell Script

### Build Rules

A target can define build rules that specialize how a file is handled when it's in a build phase in the target. For example, you might make a rule that processes assets in a custom format into PNG files during the build.

- - -

## Build Configurations

Projects typically support `Debug` and `Release` build configurations. A build configuration is a named style of build to perform. There are conventions around `Debug` and `Release` configurations, but the set of names is extensible and open. A build action in Xcode (Run, Test, Profile, Archive) targets a build configuration, and the build configuration is a set of build settings that customize the build.

Each build configuration at the project level can optionally specify one `xcconfig` file.

- - -

## Build Settings

Build settings are key-value pairs in the Xcode project format. The key is always a string, and the value is either a string or an array of strings. Xcode's build settings can be conditional on configuration, SDK, and processor architecture with support for wildcard matching. `XcodeProjectFormat` does not offer APIs to process these values in a format richer than their raw string representation.

Build settings have precedence levels, and build settings at the project level are lower precedence than build settings at the target level.

- - -

## External Dependencies

Projects can reference packages remotely or via a file reference to a local package. They can also reference local Xcode projects and use their products as inputs.

- - -

## Relationships

The project is encoded as a JSON tree, but some nodes need to form explicit references to other distant nodes. For example, a file needs to list what build phases it is a member of.

There are unique value types used to establish each of these relationships. In the previous example, a `TargetBuildPhaseReference` is used, which is composed of enough information to uniquely look up the target and build phase. Some objects have unique name requirements and can simply be referenced by name. Others don't and can either be referenced by name or identifier, and sometimes a path of names. Identifiers are UUID-like strings and are very durable but off-putting in code review. The format prefers to use self-describing name references when they're unique and otherwise uses identifiers. Since identifiers are off-putting in diffs, they're only used when an object is distantly referenced and a name reference would be ambiguous. Notably, targets and target products can be referenced by external files, so they should always have IDs.

It is the client's responsibility to decide which objects need IDs and if references should use IDs or names.

- - -

## Version Compatibility

The top-level project entity in the JSON has a `required-capabilities` JSON property. It's an array of strings. If the decoder sees an unknown string in this list, like "glow in the dark files", it throws an error using this string as a key portion of the localized description and produces a message like:

> The project requires a newer version of Xcode with support for glow in the dark files.

Future versions of this library will define new required-capabilities, and when they're used, will prevent older versions of this library from incorrectly decoding the file.
