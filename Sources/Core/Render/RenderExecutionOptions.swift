import Foundation

package enum FPSBakeoffVariant: String, CaseIterable, Codable, Sendable {
    case currentCFR
    case mixedCadenceVFR
    case stillAwareCFR

    package var displayName: String {
        switch self {
        case .currentCFR:
            return "Current CFR"
        case .mixedCadenceVFR:
            return "Plan 1 Mixed Cadence"
        case .stillAwareCFR:
            return "Plan 3 Still-Aware CFR"
        }
    }

    package var filenameSuffix: String {
        switch self {
        case .currentCFR:
            return "current-cfr"
        case .mixedCadenceVFR:
            return "plan1-mixed-cadence"
        case .stillAwareCFR:
            return "plan3-still-aware-cfr"
        }
    }
}

package struct RenderExecutionOptions: Equatable, Sendable {
    package static let `default` = RenderExecutionOptions(
        fpsBakeoffVariant: .mixedCadenceVFR,
        preserveResumableHDRCheckpoints: false
    )

    package let fpsBakeoffVariant: FPSBakeoffVariant?
    package let preserveResumableHDRCheckpoints: Bool

    package init(
        fpsBakeoffVariant: FPSBakeoffVariant? = nil,
        preserveResumableHDRCheckpoints: Bool = false
    ) {
        self.fpsBakeoffVariant = fpsBakeoffVariant
        self.preserveResumableHDRCheckpoints = preserveResumableHDRCheckpoints
    }
}
