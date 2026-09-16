//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the xcode-project-format project authors
//
// Licensed under Apache License v2.0
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation



extension XCSchema {
    /// Maps files nested in a folder into non-default, specified build phases.
    ///
    /// Specifically, maps files discovered by a ``Folder`` reference. A `BuildPhaseExceptionSet` is an exception set that adds files from a folder to a specific build phase in a specific target rather than the default build phase for the file based on its type. This is most commonly used to map a file to a copy-files build phase.
    public struct BuildPhaseExceptionSet: Equatable, Sendable {
        public var buildPhase: XCSchema.ProjectBuildPhaseReference
        public var commonProperties: XCSchema.CommonExceptionSetProperties

        public init(buildPhase: XCSchema.ProjectBuildPhaseReference, commonProperties: XCSchema.CommonExceptionSetProperties) {
            self.buildPhase = buildPhase
            self.commonProperties = commonProperties
        }
    }
}

extension XCSchema.BuildPhaseExceptionSet: XCJSON.InlineKeyedCodable {
    package func encode(with container: XCJSON.Encoder.KeyedContainer) throws {
        try container.encode(buildPhase, for: "build-phase", unconditionally: .affirmative)
        try commonProperties.encode(with: container)
    }

    package init(with container: XCJSON.Decoder.KeyedContainer) throws {
        buildPhase = try container.decode("build-phase")
        commonProperties = try .init(with: container)
    }
}

