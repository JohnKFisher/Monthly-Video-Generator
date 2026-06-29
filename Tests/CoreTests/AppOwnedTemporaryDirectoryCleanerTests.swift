@testable import Core
import Foundation
import XCTest

final class AppOwnedTemporaryDirectoryCleanerTests: XCTestCase {
    func testCleanContentsRemovesOnlyStaleAppOwnedTempChildren() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("AppOwnedTemporaryDirectoryCleanerTests-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)

        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let staleFile = root.appendingPathComponent("old.mov")
        let freshFile = root.appendingPathComponent("new.mov")
        let nestedDirectory = root.appendingPathComponent("Photos", isDirectory: true)
        let staleNestedFile = nestedDirectory.appendingPathComponent("old-photo.mov")
        try FileManager.default.createDirectory(at: nestedDirectory, withIntermediateDirectories: true)
        try Data([0x01]).write(to: staleFile)
        try Data([0x02]).write(to: freshFile)
        try Data([0x03]).write(to: staleNestedFile)

        let staleDate = now.addingTimeInterval(-(25 * 60 * 60))
        try FileManager.default.setAttributes([.modificationDate: staleDate], ofItemAtPath: staleFile.path)
        try FileManager.default.setAttributes([.modificationDate: now], ofItemAtPath: freshFile.path)
        try FileManager.default.setAttributes([.modificationDate: staleDate], ofItemAtPath: staleNestedFile.path)
        try FileManager.default.setAttributes([.modificationDate: now], ofItemAtPath: nestedDirectory.path)

        AppOwnedTemporaryDirectoryCleaner.cleanContents(
            of: root,
            now: now,
            maximumAge: 24 * 60 * 60
        )

        XCTAssertFalse(FileManager.default.fileExists(atPath: staleFile.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: staleNestedFile.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: freshFile.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: nestedDirectory.path))
    }
}
