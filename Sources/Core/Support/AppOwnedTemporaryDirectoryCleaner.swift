import Foundation

package enum AppOwnedTemporaryDirectoryCleaner {
    package static let defaultMaximumAge: TimeInterval = 24 * 60 * 60

    package static func cleanDefaultTemporaryDirectories(
        fileManager: FileManager = .default,
        now: Date = Date(),
        maximumAge: TimeInterval = defaultMaximumAge
    ) {
        let root = fileManager.temporaryDirectory.appendingPathComponent("MonthlyVideoGenerator", isDirectory: true)
        cleanContents(
            of: root,
            fileManager: fileManager,
            now: now,
            maximumAge: maximumAge
        )
    }

    package static func cleanContents(
        of directoryURL: URL,
        fileManager: FileManager = .default,
        now: Date = Date(),
        maximumAge: TimeInterval = defaultMaximumAge
    ) {
        guard maximumAge >= 0,
              let contents = try? fileManager.contentsOfDirectory(
                at: directoryURL,
                includingPropertiesForKeys: [.contentModificationDateKey, .isDirectoryKey],
                options: [.skipsHiddenFiles]
              ) else {
            return
        }

        let cutoff = now.addingTimeInterval(-maximumAge)
        for url in contents {
            let values = try? url.resourceValues(forKeys: [.contentModificationDateKey, .isDirectoryKey])
            if values?.isDirectory == true {
                cleanContents(
                    of: url,
                    fileManager: fileManager,
                    now: now,
                    maximumAge: maximumAge
                )
            }
            guard isStale(url, cutoff: cutoff) else {
                continue
            }
            try? fileManager.removeItem(at: url)
        }
    }

    private static func isStale(_ url: URL, cutoff: Date) -> Bool {
        guard let values = try? url.resourceValues(forKeys: [.contentModificationDateKey]),
              let modifiedAt = values.contentModificationDate else {
            return false
        }
        return modifiedAt < cutoff
    }
}
