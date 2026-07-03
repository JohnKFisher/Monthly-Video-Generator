# Working Changelog

Internal notes for building public-facing changelogs. Keep entries understandable to non-technical users, but not fully polished.

## Unreleased

### Added
- Queue removal and clear actions now ask for confirmation before removing queued job records or result summaries. Exported video files are not deleted by these actions.
- Full-year Photos queue scans can now be cancelled while the app is still checking months.
- The current job card now warns when the requested output filename already exists and shows the versioned filename the app will use instead.

### Changed
- Settings screens now state that changes save automatically and affect future renders or queue snapshots.
- Queue copy now makes it clearer that adding a job freezes the current form settings into that queued job.
- Auto-selected queue details now use a review-oriented label instead of implying the user explicitly selected that job.
- HDR HEVC exports now use the approved mixed-cadence timing by default, reducing file size while keeping title/opening-title motion at 30 fps. [public candidate]
- Smart mixed-cadence HDR HEVC exports now keep video sections capped at 60 fps by default for Plex/Infuse Apple TV compatibility. [public candidate]
- The main window now starts with source, title, save, and movie details before the render preview, and treats batch exports as optional instead of making the queue compete with the one-video path. [public candidate]
- Export settings now present the recommended Plex/Infuse/Apple TV output preset first, with technical codec, HDR, bitrate, frame-rate, and diagnostics controls tucked behind Advanced. [public candidate]
- The render preview now shows a ready/not-ready summary with the source, destination, and final filename, and blocks one-off or queued renders until required choices like a folder or Photos album are selected. [public candidate]
- The Source pane now includes its own Folder / Apple Photos switch and clearer Apple Photos choices for one-month versus album exports, so the first setup step no longer depends on the toolbar. [public candidate]
- Post-render status now leads with the finished movie filename and folder, with reveal/open actions nearby and diagnostics/backend details kept secondary. [public candidate]
- The year pickers now allow selecting 1979 as the earliest year.

### Fixed
- Late Photos album refreshes no longer update album selection after the user leaves album mode.
- Diagnostics JSON report write failures now appear as warnings instead of failing silently.
- Apple Photos videos with Apple-only `apac` audio now create a temporary audio bridge for FFmpeg HDR renders, preserving audio instead of failing during presentation staging.
- Advanced export help text now describes the new mixed-cadence HDR HEVC default instead of the old 30/60 fps Smart behavior.

### Reliability / Data Safety
- Added focused coverage for output filename collision previews, full-year queue scan cancellation, stale album refreshes, and diagnostics report write warnings.
- The app now removes app-owned temporary render and Photos files more aggressively, and resumable HDR checkpoints are opt-in so normal renders keep more disk space free. [public candidate]
