import Foundation
import Core
#if canImport(AppKit)
import AppKit
#endif

enum AppMetadata {
    private struct AppLinks: Decodable {
        let repositoryURL: String?
        let sidelarkLabsURL: String?
        let licenseURL: String?
        let attributionsURL: String?
    }

    static let appName = "Monthly Video Generator"
    static let headerIconResourceName = "AppHeaderIcon"
    static let appLinksResourceName = "AppLinks"
    private static let appResourceBundleName = "MonthlyVideoGenerator_MonthlyVideoGeneratorApp.bundle"

    static var shortVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "dev"
    }

    static var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "local"
    }

    static var versionBuildValue: String {
        "\(shortVersion) (\(buildNumber))"
    }

    static var exportProvenanceIdentity: OutputProvenanceAppIdentity {
        OutputProvenanceAppIdentity(
            appName: appName,
            appVersion: shortVersion,
            buildNumber: buildNumber
        )
    }

    static var versionBuildLabel: String {
        "Version \(versionBuildValue)"
    }

    static var repositoryURL: URL? {
        appLinkURL(\.repositoryURL)
    }

    static var sidelarkLabsURL: URL? {
        appLinkURL(\.sidelarkLabsURL)
    }

    static var licenseURL: URL? {
        appLinkURL(\.licenseURL)
    }

    static var attributionsURL: URL? {
        appLinkURL(\.attributionsURL)
    }

    private static func appLinkURL(_ keyPath: KeyPath<AppLinks, String?>) -> URL? {
        guard
            let bundle = appResourceBundle,
            let url = bundle.url(forResource: appLinksResourceName, withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let links = try? JSONDecoder().decode(AppLinks.self, from: data),
            let link = links[keyPath: keyPath]?.trimmingCharacters(in: .whitespacesAndNewlines),
            !link.isEmpty
        else {
            return nil
        }

        return URL(string: link)
    }

    #if canImport(AppKit)
    private static var appResourceBundle: Bundle? {
        let candidateURLs = [
            Bundle.main.resourceURL?.appendingPathComponent(appResourceBundleName, isDirectory: true),
            Bundle.main.bundleURL.appendingPathComponent(appResourceBundleName, isDirectory: true),
            Bundle.main.executableURL?.deletingLastPathComponent().appendingPathComponent(appResourceBundleName, isDirectory: true)
        ].compactMap { $0 }

        for url in candidateURLs {
            if let bundle = Bundle(url: url) {
                return bundle
            }
        }

        return nil
    }

    @MainActor
    private static func bundledImage(
        named resourceName: String,
        extension fileExtension: String
    ) -> NSImage? {
        guard
            let bundle = appResourceBundle,
            let url = bundle.url(forResource: resourceName, withExtension: fileExtension)
        else {
            return nil
        }
        return NSImage(contentsOf: url)
    }

    @MainActor
    static let headerIconImage: NSImage? = {
        bundledImage(named: headerIconResourceName, extension: "png")
    }()

    #endif
}
