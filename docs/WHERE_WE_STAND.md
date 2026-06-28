# Monthly Video Generator

Current version/build:
- `1.0.0`
- Latest checked-in build identity: `220`

Current overall status:
- Feature complete for the intended job and effectively in maintenance mode.
- The app is ready to use for folder-based and Apple Photos-based monthly video exports.
- Future work is expected to be tweaks, UX polish, reliability hardening, and small workflow refinements rather than major scope expansion.

What works now:
- Local-only macOS app workflow with no telemetry or cloud requirement.
- Folder source rendering for mixed photos and videos.
- Apple Photos rendering using month/year filtering and album selection.
- Album exports can span multiple months; the app uses the earliest dated item for Plex month/year identity and the album title for auto-managed naming.
- Light Table + Job Drawer export workflow with queue support and pause-after-current-item behavior.
- Queue job removal/clear actions now ask for confirmation, and full-year Photos queue scans can be cancelled while scanning.
- Output filename collisions are surfaced before rendering by showing the versioned filename the app will use.
- Settings for style/export defaults plus per-render title and caption editing.
- Settings are still immediate-save controls, and the Settings UI now says so explicitly.
- Plex/Infuse-oriented HDR HEVC exports with the current bundled FFmpeg/ffprobe packaging path and mixed-cadence progressive timing for smaller files.
- Packaged universal app builds that prefer native Apple Silicon execution.
- About window with copyright credit and a link to the public GitHub repository.

Known limitations and trust warnings:
- Large HDR exports can still take a long time and use substantial CPU, memory, disk, and temporary storage.
- Apple Photos exports depend on Photos permissions and can be slowed by PhotoKit/iCloud materialization.
- Real-library Photos/iCloud behavior still deserves occasional manual smoke testing because automated tests use test doubles.
- Mixed-cadence HDR outputs should be checked in Plex/Infuse for direct-play behavior, seeking, and smooth motion around title cards and transitions after timing-policy changes.
- The still-image path is intentionally conservative and can be slower than a more aggressive implementation.
- The HDR recovery/resume path exists, but parts of that UX are still somewhat technical.
- Local packaged builds are ad-hoc signed by default. Developer ID release builds now have a documented path for signing the app and DMG, submitting to Apple notarization, and stapling the accepted ticket.

Setup/runtime requirements:
- macOS 15-class environment for the current SwiftPM/app workflow.
- A full Xcode developer directory for local builds and tests. If `xcode-select` points at Command Line Tools, set `DEVELOPER_DIR` to a full Xcode app before building.
- Photos permission for Apple Photos exports.
- Enough free disk space for temporary intermediates and final exports.

Recommended next priorities:
- Keep manual smoke checks around real exports whenever a meaningful render or packaging change lands.
- Before any public packaged release, repeat a packaged-app launch plus representative folder, Photos month/year, Photos album, and full-year queue export checks against real media.
- Keep release signing/notarization credentials in Keychain or CI secrets only; do not commit Apple credentials or app-specific passwords.
- Prefer small polish and reliability passes over broad architectural churn.
- Treat render/color/HDR/output behavior as protected unless a future change is explicitly worth the risk.

Most recent durable known-good anchor:
- `known-good/20260320-v1-1-0-collage-titles`
- No current `1.0.0 (220)` known-good tag was created in this session; creating or moving tags requires explicit approval.
