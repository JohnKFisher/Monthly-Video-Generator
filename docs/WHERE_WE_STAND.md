# Monthly Video Generator

Current version/build:
- `1.0.0`
- Latest checked-in build identity: `220`

Current overall status:
- The current app is ready to use for folder-based and Apple Photos-based monthly video exports.
- A larger revamp/repositioning is expected next, including version reset work, Sidelark Labs identity cleanup, and user-facing copy cleanup.
- Until that revamp lands, treat render/color/HDR/output behavior as protected and keep changes small.

What works now:
- Local-only macOS app workflow with no telemetry or cloud requirement.
- Folder source rendering for mixed photos and videos.
- Apple Photos rendering using month/year filtering and album selection.
- Album exports can span multiple months; the app uses the earliest dated item for Plex month/year identity and the album title for auto-managed naming.
- Setup-first main window flow with body-level source selection, a Light Table render preview, ready/not-ready guidance, optional batch queue support, and pause-after-current-item behavior.
- Queue job removal/clear actions now ask for confirmation, and full-year Photos queue scans can be cancelled while scanning.
- Output filename collisions are surfaced before rendering by showing the versioned filename the app will use.
- Successful renders now show a clear finished-movie summary with the filename, folder, and quick reveal/open actions before diagnostic details.
- Settings for style/export defaults plus per-render title, caption, save location, and movie-library details. Export settings are preset-first, with technical encoding controls kept behind Advanced.
- Settings are still immediate-save controls, and the Settings UI now says so explicitly.
- Plex/Infuse-oriented HDR HEVC exports with the current bundled FFmpeg/ffprobe packaging path and mixed-cadence progressive timing; Smart video sections use standard source-fps buckets capped at 60 fps for Apple TV compatibility.
- App-owned temporary render and Photos materialization files are cleaned up more aggressively, and resumable HDR checkpoint retention is off by default with an opt-in setting.
- Packaged universal app builds that prefer native Apple Silicon execution.
- About window with current app identity and repository link. This is scheduled
  for Sidelark Labs credit/link alignment during the policy cleanup.

Known limitations and trust warnings:
- Large HDR exports can still take a long time and use substantial CPU, memory, disk, and temporary storage.
- Apple Photos exports depend on Photos permissions and can be slowed by PhotoKit/iCloud materialization.
- Real-library Photos/iCloud behavior still deserves occasional manual smoke testing because automated tests use test doubles.
- Mixed-cadence HDR outputs should be checked in Plex/Infuse for direct-play behavior, seeking, and smooth motion around title cards and transitions after timing-policy changes.
- The still-image path is intentionally conservative and can be slower than a more aggressive implementation.
- The HDR recovery/resume path exists, but checkpoint retention must be turned on in Settings before a paused or failed HDR render can be resumed.
- Local packaged builds are ad-hoc signed by default. Public distribution should
  stay honest about signing/notarization state and should not overwrite an
  already-published release artifact.

Setup/runtime requirements:
- macOS 15-class environment for the current SwiftPM/app workflow.
- A full Xcode developer directory for local builds and tests. If `xcode-select` points at Command Line Tools, set `DEVELOPER_DIR` to a full Xcode app before building.
- Photos permission for Apple Photos exports.
- Enough free disk space for temporary intermediates and final exports.
- Use `./scripts/test.sh` for SwiftPM tests so the run gets a scratch path and isolated home outside any polluted `.build/out` tree.

Recommended next priorities:
- Complete the policy-alignment cleanup captured in
  `docs/AGENT_POLICY_ALIGNMENT_REVIEW.md`, including the revamp follow-ups for
  Sidelark Labs identifiers and neutral generated video-description copy.
- Keep manual smoke checks around real exports whenever a meaningful render or packaging change lands.
- Before any public packaged release, repeat a packaged-app launch plus representative folder, Photos month/year, Photos album, and full-year queue export checks against real media.
- Keep release signing/notarization credentials in Keychain or CI secrets only; do not commit Apple credentials or app-specific passwords.
- Prefer small polish and reliability passes over broad architectural churn.
- Treat render/color/HDR/output behavior as protected unless a future change is explicitly worth the risk.

Most recent durable known-good anchor:
- `known-good/20260320-v1-1-0-collage-titles`
- No current `1.0.0 (220)` known-good tag was created in this session; creating or moving tags requires explicit approval.
