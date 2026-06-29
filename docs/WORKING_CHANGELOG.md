# Working Changelog

Internal notes for building public-facing changelogs. Keep entries understandable to non-technical users, but not fully polished.

## Unreleased

### Added
- Queue removal and clear actions now ask for confirmation before removing queued job records or result summaries. Exported video files are not deleted by these actions.
- Full-year Photos queue scans can now be cancelled while the app is still checking months.
- The current job card now warns when the requested output filename already exists and shows the versioned filename the app will use instead.
- Added an experimental in-app FPS bakeoff command that renders current HDR HEVC settings three ways into a timestamped folder, comparing current constant-FPS output against mixed-cadence and still-aware variants. [needs review]

### Changed
- Settings screens now state that changes save automatically and affect future renders or queue snapshots.
- Queue copy now makes it clearer that adding a job freezes the current form settings into that queued job.
- Auto-selected queue details now use a review-oriented label instead of implying the user explicitly selected that job.
- HDR HEVC exports now use the bakeoff-approved mixed-cadence timing by default, reducing file size while keeping title/opening-title motion at 30 fps. [public candidate]
- Smart mixed-cadence HDR HEVC exports now keep video sections capped at 60 fps by default for Plex/Infuse Apple TV compatibility. [public candidate]
- The main window now makes source, opening title, queue, and video details clearer, with final filename and save folder previews shown before optional custom name or description editing. [public candidate]

### Fixed
- Late Photos album refreshes no longer update album selection after the user leaves album mode.
- Diagnostics JSON report write failures now appear as warnings instead of failing silently.
- FPS bakeoff runs now report failure when every variant fails, instead of claiming the bakeoff completed without final output files.
- Apple Photos videos with Apple-only `apac` audio now create a temporary audio bridge for FFmpeg HDR renders, preserving audio instead of failing during presentation staging.
- Advanced export help text now describes the new mixed-cadence HDR HEVC default instead of the old 30/60 fps Smart behavior.

### Reliability / Data Safety
- Added focused coverage for output filename collision previews, full-year queue scan cancellation, stale album refreshes, and diagnostics report write warnings.
- The app now removes app-owned temporary render and Photos files more aggressively, and resumable HDR checkpoints are opt-in so normal renders keep more disk space free. [public candidate]

### Internal / Maintenance
- Clarified source-build requirements, scratch-path test recovery, current release-status truth, and the canonical `docs/WORKING_CHANGELOG.md` filename for future agent work.
- Fixed packaged app assembly so universal builds preserve separate architecture slices before combining them, and made bundled-tool architecture validation match the `lipo -archs` output used by current Xcode tools.
- Added Developer ID disk-image signing support to the DMG packaging script so notarized release artifacts can pass Gatekeeper assessment cleanly.
- Made the packaged-app build script choose an installed full Xcode developer directory when the machine is currently pointed at Command Line Tools.
