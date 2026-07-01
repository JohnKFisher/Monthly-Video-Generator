import Foundation

package enum RenderCadencePolicy: Equatable, Sendable {
    case mixedCadence
}

package struct RenderExecutionOptions: Equatable, Sendable {
    package static let `default` = RenderExecutionOptions(
        cadencePolicy: .mixedCadence,
        preserveResumableHDRCheckpoints: false
    )

    package let cadencePolicy: RenderCadencePolicy?
    package let preserveResumableHDRCheckpoints: Bool

    package init(
        cadencePolicy: RenderCadencePolicy? = nil,
        preserveResumableHDRCheckpoints: Bool = false
    ) {
        self.cadencePolicy = cadencePolicy
        self.preserveResumableHDRCheckpoints = preserveResumableHDRCheckpoints
    }
}
