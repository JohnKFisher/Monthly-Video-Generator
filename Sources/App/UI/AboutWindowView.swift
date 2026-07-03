import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

struct AboutWindowView: View {
    var body: some View {
        VStack(spacing: 18) {
            if let headerIconImage = AppMetadata.headerIconImage {
                Image(nsImage: headerIconImage)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
            }

            VStack(spacing: 6) {
                Text(AppMetadata.appName)
                    .font(.title2.weight(.semibold))

                Text("Version \(AppMetadata.versionBuildValue)")
                    .foregroundStyle(.secondary)

                Text("Local macOS app for monthly video exports.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 320)
            }

            VStack(spacing: 6) {
                Text("Copyright © 2026 Sidelark Labs and John Kenneth Fisher")
                    .font(.callout)

                if let sidelarkLabsURL = AppMetadata.sidelarkLabsURL {
                    Link("Sidelark Labs", destination: sidelarkLabsURL)
                        .font(.callout.weight(.medium))
                }

                if let repositoryURL = AppMetadata.repositoryURL {
                    Link("GitHub Repository", destination: repositoryURL)
                        .font(.callout.weight(.medium))
                }

                HStack(spacing: 12) {
                    if let licenseURL = AppMetadata.licenseURL {
                        Link("License", destination: licenseURL)
                    }
                    if let attributionsURL = AppMetadata.attributionsURL {
                        Link("Attributions", destination: attributionsURL)
                    }
                }
                .font(.callout.weight(.medium))
            }
        }
        .padding(28)
        .frame(width: 380)
    }
}
