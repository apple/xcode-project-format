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

struct ProjectCapabilityTests {
    @Test(arguments: [
        ["glow in the dark files"],
        ["glow in the dark files", "holographic targets"],
    ])
    func rejectsUnknownCapabilities(unknownCapabilities: [String]) throws {
        let known = XCSchema.Capability.knownCapabilityForTesting.capabilityDescription
        let data = try projectData(requiredCapabilities: [known] + unknownCapabilities)

        expectUnsupportedCapabilities(in: data, named: unknownCapabilities)
    }

    @Test func checksCapabilitiesBeforeMissingRequiredFields() throws {
        // No files, default-configuration, or localizations: compatibility must be checked first.
        let data = Data(#"{"required-capabilities": ["glow in the dark files"]}"#.utf8)

        expectUnsupportedCapabilities(in: data, named: ["glow in the dark files"])
    }

    @Test func acceptsKnownCapability() throws {
        let known = XCSchema.Capability.knownCapabilityForTesting
        let data = try projectData(requiredCapabilities: [known.capabilityDescription])
        let project = try XCSchema.Project(jsonRepresentation: data)

        #expect(project.requiredCapabilities == [known])
        let roundTripped = try XCSchema.Project(jsonRepresentation: project.jsonRepresentation())
        #expect(roundTripped == project)
    }

    @Test func acceptsEmptyCapabilities() throws {
        let project = try XCSchema.Project(jsonRepresentation: projectData(requiredCapabilities: []))

        #expect(project.requiredCapabilities.isEmpty)
    }

    @Test func acceptsOmittedCapabilities() throws {
        let project = try XCSchema.Project(jsonRepresentation: projectData(requiredCapabilities: nil))

        #expect(project.requiredCapabilities.isEmpty)
    }

    private func projectData(requiredCapabilities: [String]?) throws -> Data {
        var object: [String: Any] = [
            "files": [],
            "default-configuration": "Debug",
            "localizations": ["development": "en"],
        ]
        if let requiredCapabilities {
            object["required-capabilities"] = requiredCapabilities
        }
        return try JSONSerialization.data(withJSONObject: object)
    }

    private func expectUnsupportedCapabilities(in data: Data, named names: [String]) {
        do {
            _ = try XCSchema.Project(jsonRepresentation: data)
            Issue.record("Expected decoding to reject unsupported capabilities")
        } catch {
            let message = (error as NSError).localizedDescription
            #expect(message.contains("requires a newer version of Xcode"))
            // Capability storage is a Set, so the diagnostic's list order is not a contract.
            for name in names {
                #expect(message.contains(name))
            }
            #expect(!message.contains(XCSchema.Capability.knownCapabilityForTesting.capabilityDescription))
        }
    }
}
