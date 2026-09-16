# File Format Goals

This document surveys the goals of the `project.xcproj` file format, and how the file format achieves those goals.

## Goals

The primary goals of the file format are to:

* Enable an ecosystem of tools that interoperate with Xcode projects
* Make diffs in project files easily understandable
* Reduce merge conflicts in project files, and make them feel justified when they occur
* Make the file easily readable by humans
* Minimize the cost to migrate from the older `project.pbxproj` plist format, by using the same project model and only changing the on-disk representation.

- - -

### Enable an ecosystem of tools that interoperate with Xcode projects

This package provides a rich, strongly typed set of value types to represent, serialize and deserialize Xcode projects. It's used to implement Xcode's native coding and decoding of project files, so it's complete, and clients should have all of the resources they need to interoperate with this format. Being JSON5, the format is also much easier to work with on systems where this package is unavailable, but can be used as a guide to the implementer.

- - -

### Understandable Diffs

After manipulating a project in Xcode, a user should be able to show the diff to the project file, and feel the diff clearly maps to what they did in the UI, and is an appropriate size for the action they took. For example, adding one file to a target should produce one diff hunk in the project file.

To achieve this, we use several techniques.

* Organize the structure of the file similarly to the structure of the Xcode UI
* Name the JSON keys, and represent enum cases with names that are familiar and match the terms of art in Xcode.
* Carefully choose how to represent relationships in the file so that the diffs are intuitive.

Let's look at an example that does all three of these.

In Xcode, projects have files. Projects also have targets, and those targets refer to the project's files, adding additional data. The in-memory schema in Xcode is something like:

* `Project ->> Files`
* `Project ->> Target ->> Build Phase ->> Build File -> File`

When the user manipulates target membership in Xcode's UI, they typically do this through an inspector on a file. So this file format encodes the target membership information in the `Project ->> Files` portion of the JSON tree. And it eschews using elements in the JSON with type names like "Build File" because that isn't a concept the Xcode user is ever exposed to. So the result of manipulating target membership in Xcode's UI is one diff hunk adjacent to the file definition with terms like `"target-membership": [ ... set of targets ... ]` and inner values like `"header-role": "public"`, and the term `build-file` is nowhere to be found.

- - -

### Reduce merge conflicts in project files, and make them feel justified when they occur

The primary way we achieve this goal is structuring the file so that one edit in the UI results in one diff hunk in the file (see "Understandable Diffs").

When a user changes one thing in the UI, and gets one diff hunk in the file, and it's adjacent to the thing they manipulated, then the only way they'll get a merge conflict is if another user manipulates the same object. That's unlikely, and it feels justified.

When a new file is added to a project, and referenced by an existing target, this format contains the diff to the file insertion. The file references the target it's been inserted into, rather than having the target reference the file that is now a member. Either of these encodings work, but having the file reference the target results in one diff hunk instead of two. Also, if the target were to refer to its files, it would need a list. The list would have to have some order, but the order would be meaningless. Updating the list would produce a second diff, which harms readability, increases the likelihood of conflict, and makes conflict in that space feel unjustified since the order was meaningless.

- - -

### Make the file easily readable by humans

Here are some techniques used to improve legibility in the file format:

* Key names, and enum value strings use terms of art familiar from the Xcode UI
* Keys are custom ordered within dictionaries so that the type of an object can be quickly discerned
* Different structures are encoded with different white-space styles so that simple repetitive objects collapse to one line, and big important objects take many lines.
* Values are only encoded when they differ from the assumed default minimizing file content.
* Dictionary nesting is compressed relative to the swift types that back the JSON objects, with many objects sharing their parent's coding container.
* Some multi-component values densely encode to a single string that is parsed back into its components at decode time. This is easier to read during diff review, but more cumbersome to write a decoder for, and is precisely the point of this library.

- - -

### Minimize the cost to migrate from the older `project.pbxproj`

This project is largely a different flavor of its predecessor `project.pbxproj`, but still carries all of the same information. It's a reimagining of the text used to encode the project format, but not the data held by the project format. This makes it immediately accessible to all Xcode projects that can use Xcode 27 and later.
