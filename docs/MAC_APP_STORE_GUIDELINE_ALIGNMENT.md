# Mac App Store Guideline Alignment Report

Date: 2026-07-05

Scope: current `main` checkout of Monthly Video Generator. This is an engineering and product-risk review, not legal advice. The legal/license findings should be checked by counsel before any paid or public Mac App Store submission.

## Bottom Line

The app has a credible Mac App Store product shape: it is a native macOS app, does local media processing, uses Apple Photos through PhotoKit, has no login, no ads, no analytics, no hidden network service, and no obvious private Apple API use in the inspected code.

But the app is **not Mac App Store-ready as it stands now**. There are two large blockers:

1. **Current packaging is not sandboxed or App Store-submission shaped.** `scripts/build_app.sh` generates a normal signed `.app` with `Info.plist`, but there is no entitlement file and no App Sandbox signing path. Apple says Mac App Store apps must be appropriately sandboxed and self-contained.
2. **The current bundled FFmpeg toolchain is GPL-enabled and central to the app.** The repo itself records this as requiring GPL-compatible redistribution obligations. That is the highest scuttle-risk issue because App Store legal/distribution terms and GPL obligations can be difficult or impossible to reconcile depending on the exact binary, linked libraries, App Store terms, and the app's own license/commercial plan.

If the FFmpeg/App Store licensing route cannot be made acceptable, the project is probably better aimed at **direct Developer ID distribution** or a **substantial native-render rewrite** before spending weeks on Mac App Store polish.

## Apple Sources Used

- Apple App Review Guidelines, especially 2.4.5, 2.5.2, 5.1.1, and 5.2.1: https://developer.apple.com/app-store/review/guidelines/
- Apple App Privacy Details: https://developer.apple.com/app-store/app-privacy-details/
- Apple App Sandbox documentation: https://developer.apple.com/documentation/security/app-sandbox
- FFmpeg legal page for license posture: https://ffmpeg.org/legal.html

## Current Alignment

### Native App Model

Current state: aligned.

Evidence:

- `Package.swift` targets macOS 15 and builds a native Swift/SwiftUI executable.
- `Sources/App/AppMain.swift` uses standard SwiftUI scenes: main window, About window, and Settings.
- No web runtime, updater framework, login provider, payment SDK, ad SDK, or analytics SDK showed up in source/package scans.

Guideline relevance:

- App Review 2.5.1 expects public APIs and current-platform compatibility.
- App Review 2.4.5(vii) disallows non-App-Store update mechanisms for Mac App Store apps; I did not find Sparkle or a custom updater.

Fix difficulty: none for the current shape.

Damage if removed: not applicable.

### User Value / Completeness

Current state: mostly aligned, assuming the app is stable in real media smoke tests.

Evidence:

- `docs/WHERE_WE_STAND.md` says the current app is ready for folder-based and Apple Photos-based monthly exports.
- The app has concrete user-facing workflows: folder source, Apple Photos month/year source, Apple Photos album source, queued full-year Photos renders, style/export settings, progress, output reveal, and diagnostics.

Guideline relevance:

- App Review 2.1 rejects incomplete, crashing, or obviously broken apps.
- App Review 2.3 requires metadata and screenshots to accurately reflect the core experience.

Fix difficulty: low to moderate. Before submission, produce App Review notes and screenshots that honestly show local media export, Photos permission use, bundled processing time, and output destinations.

Damage if removed: not applicable.

### Photos Access

Current state: mostly aligned, with review-sensitive edges.

Evidence:

- `scripts/build_app.sh` writes `NSPhotoLibraryUsageDescription`: "Monthly Video Generator needs Photos access to build selected month or album exports from your photos and videos."
- `PhotoKitMediaDiscoveryService` uses `PHPhotoLibrary.authorizationStatus(for: .readWrite)` and requests authorization only through `PHPhotoLibrary.requestAuthorization(for: .readWrite)`.
- `MainWindowInputPane` warns that Apple Photos exports may inspect selected items and download iCloud originals needed for render.
- Denied/restricted states tell users folder exports still work, and the UI can open Photos privacy settings.
- Album and month/year discovery read Photos metadata and assets through PhotoKit; materialization writes temporary copies into app-owned temporary locations.

Guideline relevance:

- App Review 5.1.1(ii) requires consent and clear purpose strings for data access.
- App Review 5.1.1(iii) says apps should request only data relevant to core functionality, and where possible use pickers/share sheets instead of full protected-resource access.

Risk:

- Full-library month/year scanning is broader than a picker-only workflow. It appears defensible because the core product is "make a monthly video from Photos," but App Review may ask why full Photos access is needed.
- `.readWrite` looks broad, but PhotoKit access levels are effectively `.addOnly` or `.readWrite`; the app needs read access, so this is probably the right PhotoKit access level.
- iCloud-backed Photos materialization can download originals locally. The current UI discloses this, which is good.

Fix difficulty: low to moderate.

- Add explicit App Review notes explaining why Photos access is core, what is read, that media stays local, and that folder mode works without Photos.
- Consider adding an in-app Privacy link before submission.
- If Apple pushes back on full-library access, a picker/limited-selection mode would be moderate to hard because month/year automation depends on library-wide discovery.

Damage if removed:

- Removing Photos access would be severe. It would cut one of the app's main sources and leave only folder exports.
- Replacing full-library/month scans with a manual picker would be moderate to severe. The app would remain useful, but lose much of its "monthly automation" value.

### Local File Access

Current state: useful, but not sandbox-ready.

Evidence:

- Folder input uses `NSOpenPanel` through `OpenPanelFolderSelector`.
- Output defaults to `~/Movies/Monthly Video Generator`.
- `AppShellPreferencesStore` persists bookmarks with `.minimalBookmark`, but does not create security-scoped bookmarks and does not call `startAccessingSecurityScopedResource()`.
- `OutputPathResolver` creates output directories and writes final output under the selected/default output directory.
- Run reports include absolute source/output/diagnostics paths.

Guideline relevance:

- App Review 2.4.5(i) requires Mac App Store apps to be appropriately sandboxed and to follow macOS file-system rules.
- App Review 2.5.2 says apps may not read/write data outside the designated container except through allowed mechanisms.

Risk:

- A sandboxed build will likely fail or lose access to remembered folders unless the app uses security-scoped bookmarks.
- The default write to `~/Movies/Monthly Video Generator` is not safe to assume in a sandbox unless covered by the right entitlement or explicit user selection.
- The current code remembers folders, but not in a way that preserves sandbox access across launches.

Fix difficulty: moderate.

- Add App Sandbox entitlements.
- Add user-selected read/write entitlement.
- Convert persisted folder bookmarks to security-scoped bookmarks.
- Wrap reads/writes in `startAccessingSecurityScopedResource()` / `stopAccessingSecurityScopedResource()`.
- Revisit the default output path: either use an app container default or force the user to choose an output folder before first render.
- Run real packaged sandbox smoke tests for folder input, folder output, Photos month/year, Photos album, diagnostics, and queued renders.

Damage if removed:

- Removing arbitrary folder input/output would be severe.
- Moving the default output into the app container would be moderate damage because exported videos become harder to find.
- Requiring explicit folder selection is low to moderate damage and probably the best App Store-compatible route.

### App Sandbox / Entitlements / Packaging

Current state: blocker.

Evidence:

- No `*.entitlements` file exists in the checkout.
- `scripts/build_app.sh` generates `Info.plist`, signs binaries, and creates a normal app bundle, but does not sign with App Sandbox entitlements.
- Current distribution docs discuss Developer ID signing/notarization and DMG packaging, not Mac App Store archive/submission packaging.

Guideline relevance:

- App Review 2.4.5(i) says Mac App Store apps must be appropriately sandboxed.
- App Review 2.4.5(ii) requires Xcode-provided packaging/submission technologies, self-contained app bundles, and no third-party installers.

Risk:

- This alone would block a Mac App Store submission.
- It is not just packaging paperwork. Sandboxing changes runtime behavior for file access, subprocesses, temporary directories, app support directories, and possibly FFmpeg execution.

Fix difficulty: moderate to high.

- Add an App Store build configuration or separate packaging path.
- Add entitlements for sandbox, user-selected files, Photos, and any other strictly required capabilities.
- Build/archive/sign through an App Store-compatible Xcode path or a carefully equivalent `xcodebuild`/`productbuild` flow.
- Validate with a sandboxed packaged app, not only `swift test`.

Damage if removed:

- Removing sandbox-incompatible assumptions may mildly hurt UX but should not damage the app if done carefully.
- If FFmpeg subprocess execution or broad file writes cannot be made to work inside the sandbox, damage becomes severe.

### Bundled FFmpeg / GPL / License Compliance

Current state: highest risk.

Evidence:

- `docs/THIRD_PARTY.md` says the project ships a bundled FFmpeg toolchain for HDR exports.
- `third_party/ffmpeg/PROVENANCE.txt` records OSXExperts static macOS builds for arm64 and x64 FFmpeg/ffprobe.
- `docs/THIRD_PARTY.md` says the committed binaries report GPL-enabled configurations, and the x64 slice reports `--enable-version3`.
- `docs/ATTRIBUTIONS.md` marks the bundle as `gpl-enabled-needs-final-redistribution-audit`.
- The app's default/core export path relies on bundled FFmpeg first for HDR/HEVC behavior.

Guideline/legal relevance:

- App Review 5.2.1 requires the app submitter to own or have licensed the relevant intellectual property rights.
- Apple says developers are responsible for legal compliance in every location where the app is available.
- FFmpeg's own legal page says FFmpeg is LGPL by default, but optional GPL parts make the GPL apply to all of FFmpeg when used. It also warns to compile without `--enable-gpl` for LGPL compliance and to avoid GPL libraries such as libx264.

Risk:

- This may be a project-scuttling issue for Mac App Store distribution.
- Even if the app communicates with FFmpeg as an executable rather than linking libraries, the app bundle redistributes GPL-enabled binaries inside an Apple-controlled distribution channel. That needs legal review before betting the project on it.
- The current x64 and arm64 slices are from different upstream FFmpeg versions, which is not itself a guideline problem but increases audit complexity.
- Source-offer, notices, exact configure flags, corresponding source, patent exposure, GPLv3/DRM/App Store terms, and commercial distribution all need to be resolved before submission.

Fix difficulty: hard.

Possible paths:

- **Direct distribution path:** keep FFmpeg, satisfy license/source/notice obligations, distribute outside the Mac App Store via Developer ID notarized DMG. This is likely the fastest path.
- **LGPL-only FFmpeg path:** replace current binaries with a carefully built LGPL-only FFmpeg, remove GPL encoders/libraries, provide exact source and notices, and verify the app still meets output-quality needs. This may still need counsel because App Store terms and LGPL obligations must coexist.
- **Native Apple pipeline path:** remove FFmpeg dependency from the shipping app and implement required export behavior with AVFoundation/VideoToolbox/Core Image/Metal. This is the most App Store-native route but likely the largest engineering rewrite.

Damage if removed:

- Severe. The current app's protected core value is high-quality HDR/HEVC monthly video export, and repo docs explicitly treat bundled FFmpeg as a required packaging input.
- Removing FFmpeg without a replacement would likely gut HDR tone mapping, xfade/acrossfade composition, encoder behavior, ffprobe inspection, and compatibility tuning.

### Executing Bundled and System Binaries

Current state: partially aligned, but needs App Store-specific tightening.

Evidence:

- `FFmpegHDRRenderer`, `FFmpegCapabilityProbe`, `FFprobeSourceMetadataProbe`, and `FFmpegBinaryResolver` launch FFmpeg/ffprobe via `Process`.
- `FFmpegBinaryResolver` can discover system FFmpeg in `PATH`, `/opt/homebrew/bin`, `/usr/local/bin`, and `/usr/bin`.
- Export settings include `bundledPreferred`, `autoSystemThenBundled`, `systemOnly`, and `bundledOnly`.

Guideline relevance:

- App Review 2.4.5(ii) requires self-contained bundles and no shared-location installs.
- App Review 2.4.5(viii) says Mac App Store apps may not rely on optionally installed technologies.
- App Review 2.5.2 restricts executing code that introduces or changes app functionality.

Risk:

- A bundled, signed helper executable inside `Contents/Resources` may be reviewable if it is self-contained and its license is clean, but this should be validated in a sandboxed package.
- System FFmpeg fallback is a bigger Mac App Store risk because it relies on optionally installed external code and can materially change export behavior after review.
- `MVG_BUNDLED_FFMPEG_ROOT` lets an environment variable redirect the bundled root. That is useful for local testing but should not affect a store build.

Fix difficulty: low to moderate if bundled FFmpeg remains acceptable; hard if FFmpeg itself must be removed.

- For a Mac App Store build, remove or compile out system-only and system-first modes.
- Disable `MVG_BUNDLED_FFMPEG_ROOT` in release/store builds.
- Keep only signed, app-bundled helpers whose exact provenance and license are reviewed.
- Ensure subprocesses are killed/cancelled when the app quits or render is cancelled.

Damage if removed:

- Removing system fallback is low damage if the bundled toolchain remains strong.
- Removing all subprocess execution is severe unless the renderer is rewritten around native APIs.

### Network Activity

Current state: aligned.

Evidence:

- Source scans found no `URLSession`, network framework use, sockets, background network service, analytics, or telemetry.
- In-app external links are static links to GitHub, Sidelark Labs, license, and attributions.
- The only "download" behavior found in runtime app code is PhotoKit materialization of iCloud-backed Photos originals through Apple's Photos framework, disclosed in UI copy.

Guideline relevance:

- App Privacy labels must accurately disclose collection/transmission.
- App Review 2.5.2 disallows downloading code/resources that add functionality.

Risk:

- Low. External links are normal.
- App Review notes/privacy policy should clarify that media processing is local and the app does not upload media.

Fix difficulty: low.

Damage if removed: low; external links could be removed with little product damage, though license/attribution access would be worse.

### Privacy Policy and Privacy Nutrition Label

Current state: missing for App Store readiness.

Evidence:

- `Sources/App/Resources/AppLinks.json` has repository, Sidelark Labs, license, and attributions URLs, but no privacy policy URL.
- `AboutWindowView` links to Sidelark Labs, GitHub, License, and Attributions, but not Privacy.
- Source scans did not find telemetry or transmitted data collection.
- Diagnostics/run reports are local files but can include absolute source/output paths and render/backend information.

Guideline relevance:

- App Review 5.1.1(i) requires a privacy policy link in App Store Connect metadata and within the app.
- Apple App Privacy Details require a clear understanding of each data type used by the app and third parties.

Risk:

- Missing privacy policy/link is a straightforward rejection risk.
- The app probably can claim no data collected by the developer if it truly does not transmit anything, but the privacy policy still needs to explain local media/Photos access, iCloud Photos materialization, local diagnostics, and support-sharing expectations.

Fix difficulty: low.

- Publish a privacy policy URL.
- Add a Privacy link in About or Settings.
- Create an App Privacy label based on local-only processing/no collection, unless support workflows or crash reports are later added.

Damage if removed: none. This is additive documentation/UI.

### Diagnostics and Reports

Current state: acceptable for local-only use, but needs App Store/support hygiene.

Evidence:

- `RunReportService` writes local JSON reports with source description, output path, diagnostics log path, backend summary, export profile, chapters, and timing audits.
- For folder sources, source description includes the absolute folder path.
- `MainWindowViewModel` writes diagnostics next to outputs when enabled.

Guideline relevance:

- App Review 5.1.1 covers collection, consent, retention/deletion, and user data handling.
- App Privacy Details treats diagnostics and user content as data types when collected by the developer or third parties.

Risk:

- Local-only diagnostics are not a blocker.
- If the app later asks users to email/share diagnostics, absolute paths and media-derived metadata become privacy-sensitive.

Fix difficulty: low.

- Keep diagnostics opt-in or clearly user-visible.
- Add a redacted support export before asking users to share logs.
- Document in the privacy policy that diagnostics stay local unless the user chooses to share them.

Damage if removed:

- Low to moderate. Removing diagnostics would make support/debugging harder but would not hurt the core render experience.

### Media Rights / Third-Party Source Downloads

Current state: aligned for user-owned local/Photos media, with review-note clarity needed.

Evidence:

- Sources are user-selected folders and Apple Photos assets.
- No YouTube, Apple Music, SoundCloud, Vimeo, or general web-download code was found.
- The app converts/exports media the user supplies or has in Photos.

Guideline relevance:

- App Review 5.2.3 warns against saving/converting/downloading media from third-party sources without authorization.

Risk:

- Low if metadata and review notes are clear that users provide their own media.
- The app should not market itself as a tool for ripping/downloading third-party services.

Fix difficulty: low.

Damage if removed: not applicable.

### Background Processes / Login Items / Persistence

Current state: aligned.

Evidence:

- No `SMAppService`, launch agent, login item, daemon, privileged helper, or updater was found.
- FFmpeg subprocesses are render-scoped rather than persistent background services.

Guideline relevance:

- App Review 2.4.5(iii) restricts auto-launch and processes that continue without consent after quit.

Risk:

- Low, but cancellation/quit behavior should be tested in a packaged app while FFmpeg is rendering.

Fix difficulty: low if any leak is found.

Damage if removed: not applicable.

### Apple Trademarks / Product Positioning

Current state: likely aligned with careful metadata.

Evidence:

- In-app copy mentions Apple Photos and Apple TV compatibility in functional descriptions.
- `ExportProfileManager` describes a Plex + Infuse on Apple TV 4K default.

Guideline relevance:

- App Review 2.3 requires accurate metadata.
- App Review 5.2.1 covers third-party rights and misleading representations.

Risk:

- Low in-app, but App Store metadata should avoid implying Apple endorsement or affiliation.
- Phrases like "Apple Photos exports" are functional and likely acceptable; marketing should say "works with photos and videos from Apple Photos" rather than implying partnership.

Fix difficulty: low.

Damage if removed: low.

## Risk Matrix

| Area | Store risk | Fix difficulty | Damage if removed |
| --- | --- | --- | --- |
| Missing sandbox/App Store packaging | Blocker | Moderate-high | Low-moderate if fixed carefully |
| GPL-enabled bundled FFmpeg | Potential blocker / scuttle risk | Hard | Severe |
| System FFmpeg fallback | Medium-high | Low-moderate | Low if bundled FFmpeg stays |
| Non-security-scoped bookmarks/default `~/Movies` output | High once sandboxed | Moderate | Low-moderate |
| Missing in-app privacy policy link | High but simple | Low | None |
| Photos full-library access | Medium | Low-moderate, hard if picker-only required | Severe if removed |
| Local diagnostics with full paths | Low-medium | Low | Low-moderate |
| External links/no network collection | Low | Low | Low |
| No updater/login/background service | Aligned | None | None |

## Practical Paths Forward

### Path A: Direct Distribution First

Keep the current FFmpeg-centered architecture. Ship outside the Mac App Store using Developer ID signing/notarization, while completing FFmpeg license/source-offer compliance.

Effort: lowest.

Product damage: none.

Store outcome: does not solve Mac App Store, but avoids the biggest uncertainty.

Best when: the app's core value depends on the existing FFmpeg output path and the Mac App Store is optional.

### Path B: Store Build With Bundled, Audited FFmpeg

Create a Mac App Store build variant: sandboxed, no system FFmpeg fallback, no environment override, security-scoped folders, privacy policy link, App Store package/archive flow. Separately audit or replace FFmpeg binaries to a legally acceptable form.

Effort: moderate-high plus legal review.

Product damage: low if FFmpeg can stay.

Store outcome: possible only if counsel is comfortable with the FFmpeg/license/App Store story.

Best when: Mac App Store is important and the legal answer on FFmpeg is favorable.

### Path C: Native Store Rewrite

Replace the shipping FFmpeg path with native AVFoundation/VideoToolbox/Core Image/Metal equivalents, keeping FFmpeg only for non-store/direct builds or removing it entirely.

Effort: high.

Product damage during transition: high risk until output quality matches current behavior.

Store outcome: cleanest technical/policy story.

Best when: Mac App Store is mandatory and FFmpeg licensing cannot be resolved.

## Recommended Next Checks

1. Ask counsel or a qualified open-source licensing expert: "Can this exact app bundle redistribute these exact GPL-enabled FFmpeg/ffprobe binaries through the Mac App Store under our intended app license and pricing?"
2. Prototype a sandboxed local build before any UI polish. Verify folder input, output folder persistence, Photos month/year render, Photos album render, FFmpeg launch, cancel/quit during render, diagnostics, and app relaunch.
3. Decide whether a Mac App Store build may remove system FFmpeg fallback and force bundled-only rendering.
4. Add a privacy policy page and an in-app Privacy link.
5. Draft App Review notes explaining: local-only processing, why Photos access is needed, no media upload, no third-party downloads, bundled render helper purpose, and where outputs are written.

## Honest Viability Assessment

The app itself is not disqualified by its concept. A local Mac app that makes videos from a user's folders or Photos library can fit App Store rules.

The current implementation has one ordinary App Store readiness gap and one existential risk:

- **Ordinary gap:** sandbox/package/privacy-policy work. This is real work but normal.
- **Existential risk:** GPL-enabled FFmpeg as a required bundled render tool. If that cannot be made App Store-compatible, the Mac App Store plan should probably stop or pivot before more product work is spent on store readiness.

