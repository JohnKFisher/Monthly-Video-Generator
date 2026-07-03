# Agent Policy Alignment Review

Date: 2026-07-01

This file tracks agent-policy alignment findings from the updated `AGENTS.md`
and `docs/agent-rules/` audit. It records the finding, John's reply, and the
intended follow-up or resolution.

## Findings 1-5

### 1. Bundled Easter Egg Image Metadata

Finding:
`Sources/App/Resources/JohnKennethEasterEgg.jpeg` is tracked and contains EXIF,
XMP, and GPS metadata. This is not aligned with the privacy/data rules for
committed artifacts.

John's reply:
If the easter egg is still accessible, remove the metadata. If it is no longer
accessible, remove the file entirely. Do not require provenance/rights
documentation because this is a personal photo.

Follow-up:
Check whether the easter egg image is still reachable in the app. Then either
strip metadata from the image or remove the unused file.

Resolution:
Removed the unused easter egg image resource and its metadata surface.

### 2. About Window Credit And Links

Finding:
The About window credits only John Kenneth Fisher and links GitHub. Current
policy expects Sidelark Labs and John Kenneth Fisher credit, plus relevant links
and acknowledgments where practical.

John's reply:
Update the About window to meet current policy.

Follow-up:
Revise the About window to include Sidelark Labs credit/linking and appropriate
license or acknowledgment access.

Resolution:
Aligned the About window copy with Sidelark Labs plus John Kenneth Fisher
credit and added repository, license, and attribution links.

### 3. README Scope And Style

Finding:
The README is longer and more status/history-oriented than the current stripped
back README policy, and it does not point to Sidelark Labs.

John's reply:
The README should likely be entirely rewritten to match the much more stripped
back current policy.

Follow-up:
Rewrite the README as a minimal current project overview with accurate build,
distribution, and Sidelark Labs context.

Resolution:
Rewrote the README as a stripped-back current overview and removed stale
personal release-signing guidance.

### 4. Bundled FFmpeg Licensing And Attribution

Finding:
`docs/THIRD_PARTY.md` and `third_party/ffmpeg/PROVENANCE.txt` document source
URLs and checksums, but the actual redistribution/license obligations for the
bundled FFmpeg/ffprobe binaries are not resolved clearly.

John's reply:
Fix this, with assistance to ensure it is done properly.

Follow-up:
Audit the exact bundled FFmpeg distributions, identify license and attribution
obligations, then update third-party documentation and any app-facing
acknowledgment surface needed.

Resolution:
Added `docs/ATTRIBUTIONS.md`, linked it from the About surface, and updated
third-party documentation to treat the current FFmpeg bundle as GPL-enabled
pending final redistribution audit.

### 5. Diagnostic Output Privacy And Disclosure

Finding:
Diagnostics are opt-in, but the UI does not clearly disclose that logs/reports
may include local paths, filenames, titles, Plex metadata, and technical render
details. Current policy prefers local, minimal, redacted, opt-in diagnostics
unless more detail is clearly surfaced.

John's reply:
Fix this as much as possible without weakening the diagnostic value of the
output.

Follow-up:
Add disclosure and targeted redaction/minimization where it does not reduce
diagnostic usefulness. Preserve the data needed to debug render, Photos,
FFmpeg, path, and metadata issues.

Resolution:
Added diagnostics disclosure in the app and kept detailed local diagnostics
available for support/debug value.

## Findings 6-10

### 6. Absolute Paths In HDR Reference Links

Finding:
`docs/HDR_COLOR_REFERENCE.md` links to source/docs files using absolute paths
from an older checkout. This is brittle because the project often moves around
the filesystem.

John's reply:
Update these to avoid absolute paths entirely.

Follow-up:
Replace absolute filesystem links in docs with relative repo links.

Resolution:
Replaced absolute HDR reference links with relative repository links.

### 7. Personal Release-Signing Values In README

Finding:
The README includes personal/local release-signing values such as a specific
Xcode beta path, Developer ID identity, and notary keychain profile.

John's reply:
Remove this entirely.

Follow-up:
Remove the personal release-signing flow from the README as part of the README
rewrite or a narrower docs cleanup.

Resolution:
Removed personal release-signing values from the README.

### 8. Placeholder Release Notes Fallback

Finding:
`.github/workflows/release.yml` can publish fallback release notes saying
`Packaging and repo-alignment updates for this release.` The updated policy says
not to use placeholder release notes.

John's reply:
Resolve this.

Follow-up:
Change release-note generation so releases use real release-note source
material or fail/require explicit notes when meaningful notes cannot be
generated.

Resolution:
Changed release-note generation to use public `docs/WORKING_CHANGELOG.md`
Unreleased bullets and fail when no release-note source exists.

### 9. Internal Maintenance Items In Working Changelog

Finding:
`docs/WORKING_CHANGELOG.md` includes internal maintenance entries even though
the updated policy says the working changelog should be release-intended,
user-facing source material rather than internal-only notes.

John's reply:
Align to the new policy.

Follow-up:
Move or remove internal-only maintenance notes from the working changelog and
keep only user-facing release-note candidates there.

Resolution:
Removed the internal maintenance section from the working changelog.

### 10. Primary Status Surface Exposes Debug Details

Finding:
The main status surface still exposes artifact, backend, diagnostics, and
snapshot source path details in the primary flow. The updated policy says the
app is past the dev-debug stage and primary flows should avoid technical
internals unless the user is in an advanced or diagnostic context.

John's reply:
Align this because the project is past the dev-debug stage.

Follow-up:
Move technical status details behind diagnostics/details affordances while
keeping finished filename, folder, and user-actionable render status visible.

Resolution:
Removed primary status-display lines for artifact/backend/diagnostics/snapshot
source paths while preserving user-facing render status and finished-output
actions.

## Findings 11-15

### 11. Diagnostics JSON Sidecar Can Overwrite Existing Files

Finding:
Diagnostics JSON is written next to the exported movie using the movie basename
and `.json` extension. That can overwrite an existing user-owned JSON file.

John's reply:
Make this collision safe.

Follow-up:
Change diagnostics report writing to avoid overwrites, such as by using a
collision-safe filename or a diagnostics-specific location.

Resolution:
Diagnostics JSON reports now use a `-diagnostics` basename and incrementing
suffixes instead of overwriting an existing file.

### 12. Photos Permission-Denied Copy Is Too Thin

Finding:
When Photos access is denied or unavailable, the album-loading state only says
to allow Photos access. It does not explain what is limited, what still works,
or how to recover.

John's reply:
Fix this.

Follow-up:
Update permission-denied copy to explain that Photos exports need access, folder
exports still work, and access can be restored in System Settings.

Resolution:
Updated Photos permission-denied copy with scope, fallback, and recovery
instructions.

### 13. Photos Local Identifiers In User-Facing Errors And Reports

Finding:
PhotoKit album and asset local identifiers can appear in normal error messages
and diagnostics/report descriptions.

John's reply:
Fix this unless keeping identifiers is genuinely useful to the end user.

Follow-up:
Audit where Photos identifiers surface. Remove them from normal user-facing
copy unless they provide real end-user value; if still needed for debugging,
keep them only in explicit diagnostics.

Resolution:
Removed Photos local identifiers from normal album/asset error descriptions and
fallback render source descriptions.

### 14. iCloud-Backed Photos Download Under-Disclosure

Finding:
PhotoKit materialization allows network access for iCloud-backed originals, but
normal Photos-source UI does not clearly disclose before rendering that exports
may download originals and take extra time/storage.

John's reply:
Fix the under-disclosure.

Follow-up:
Add concise Photos-source or pre-render copy explaining that iCloud-backed
Photos originals may be downloaded locally during export.

Resolution:
Added Photos-source copy and Smart inspection copy disclosing possible iCloud
original downloads.

### 15. Stale Photos Privacy Prompt

Finding:
The generated `NSPhotoLibraryUsageDescription` says the app needs Photos access
to build month-based slideshows, but the app now supports both month and album
exports with mixed photos and videos.

John's reply:
Update the copy.

Follow-up:
Update the packaged app privacy string to accurately cover selected Photos
month/album exports and mixed photo/video use.

Resolution:
Updated the generated Photos privacy usage string for selected month or album
photo/video exports.

## Findings 16-20

### 16. Generated Graphify Output Is Tracked

Finding:
`graphify-out/` generated graph output and cache files are tracked, while the
updated context-efficiency policy treats generated graph/output folders as
default exclusions.

John's reply:
Update `.gitignore` and remove those files from git.

Follow-up:
Add `graphify-out/` and other generated output folders such as `output/` to
`.gitignore` as appropriate, then stop tracking existing generated graph output
without deleting useful local copies unless explicitly intended.

Resolution:
Added generated output folders to `.gitignore` and removed `graphify-out/` from
git tracking while leaving local ignored copies intact.

### 17. License Copyright Credit

Finding:
`LICENSE` credits only John Kenneth Fisher, while the updated licensing/About
policy expects Sidelark Labs and John Kenneth Fisher credit for this project.

John's reply:
Update the license copyright.

Follow-up:
Update the license copyright line to the approved Sidelark Labs plus John
Kenneth Fisher form.

Resolution:
Updated the license copyright line.

### 18. Existing Release Artifact Clobbering

Finding:
The release workflow edits an existing release and uploads the DMG with
`--clobber`, which can rewrite an already published artifact.

John's reply:
Align this.

Follow-up:
Change release behavior so existing releases/artifacts are not silently
overwritten. Prefer failing or requiring an explicit manual override, with new
patch/build releases for post-publication fixes.

Resolution:
Changed release publishing to refuse an existing GitHub release instead of
editing/clobbering it.

### 19. Commit-Subject Release Notes

Finding:
The release workflow generates release notes from commit subjects instead of a
deliberate release-note source, which can pull internal implementation noise
into public release notes.

John's reply:
Align this.

Follow-up:
Generate release notes from `docs/WORKING_CHANGELOG.md` or another approved
release-note source, and fail or require review when no suitable notes exist.

Resolution:
Release notes now come from `docs/WORKING_CHANGELOG.md` public Unreleased
entries.

### 20. Unpinned System ffprobe Fallback In Fetch Helper

Finding:
`scripts/fetch_ffmpeg_bundle.sh` can fall back to copying `ffprobe` from `PATH`
when no ffprobe payload is supplied, without a supplied checksum or distribution
decision.

John's reply:
Align this.

Follow-up:
Require an explicit pinned `ffprobe` payload and SHA256 for bundle refreshes, or
make PATH fallback clearly local-only and unable to feed committed/release
packaging.

Resolution:
Removed the unpinned PATH fallback from the FFmpeg fetch helper; ffprobe must
come from the pinned ffmpeg payload or an explicit pinned ffprobe payload.

## Findings 21-25

### 21. Release Tag Does Not Include Build Number

Finding:
The release workflow triggers when either `VERSION` or `BUILD_NUMBER` changes,
but the release tag is only `v${VERSION}`. A build-number-only release therefore
targets the same GitHub release/tag as the prior build of that marketing
version, which conflicts with the updated release rule to avoid rewriting
published releases and to prefer a new patch/build after publication.

John's reply:
We are going to reset the version numbers for the upcoming revamp, so fix this
however makes sense.

Follow-up:
Align the release trigger, tag, and artifact identity. Either include the build
number in release tags/names when build-only releases are valid, or stop
publishing on build-number-only changes and require a new patch version for a
new public release.

Resolution:
Use build-specific GitHub release tags/names and refuse to overwrite an existing
release.

### 22. Embedded Output Metadata Namespace Uses Old Personal Identifier

Finding:
Exported videos embed provenance keys under
`com.jkfisher.monthlyvideogenerator`, while the project profile identifies
Monthly Video Generator as a Sidelark Labs project and says future public
identifiers should use `com.sidelarklabs.*` unless a project decision says
otherwise.

John's reply:
We will be renaming and repositioning this app and intend to use a
`com.sidelarklabs.*` ID for the new iteration. Prep is fine if sensible;
otherwise fix this later.

Follow-up:
Decide whether embedded metadata keys are covered by the approved bundle-ID
exception. If not, add Sidelark Labs metadata keys in a backward-compatible way,
likely preserving old keys for existing tooling while writing the new namespace
going forward.

Resolution:
Deferred to the revamp. When the bundle/app identity moves to Sidelark Labs,
update embedded output metadata keys in a backward-compatible way.

### 23. No Machine-Readable Attribution Manifest

Finding:
The project has `docs/THIRD_PARTY.md` and FFmpeg provenance, but no
machine-readable `ATTRIBUTIONS.md` even though the dependencies/assets policy
says to keep one where practical for bundled assets/libraries and attribution
requirements.

John's reply:
Please create what we need.

Follow-up:
Add a machine-readable attribution manifest or convert the existing
third-party/provenance documentation into a clearly structured attribution
source. Include FFmpeg source, license, redistribution notes, and whether
attribution is required.

Resolution:
Create `docs/ATTRIBUTIONS.md` as the machine-readable attribution source.

### 24. Status Document Still Contains Distribution/About Claims That Will Drift

Finding:
`docs/WHERE_WE_STAND.md` still says the About window has copyright credit and a
public GitHub link, and it describes a Developer ID signing/notarization path.
Those statements will be stale once the About, README, and release policy
alignment items above are resolved.

John's reply:
Please align document.

Follow-up:
After the approved policy-alignment changes are made, update
`docs/WHERE_WE_STAND.md` so it remains short, current, and honest about the
actual About surface and distribution path.

Resolution:
Align `docs/WHERE_WE_STAND.md` with the active policy-cleanup/revamp state.

### 25. Default Embedded Description Uses Personal Family Copy

Finding:
The default Plex/video-library description is hardcoded as
`Fisher Family Monthly Video for ...`. That personal copy can be embedded into
exported media by default, while the updated project identity is Sidelark Labs
and the new docs policy favors stripped-back current public/user-facing copy.

John's reply:
We will need to fix this in the revamp. Leave it for now, but make a note
somewhere that it needs to be done.

Follow-up:
Decide whether this personal default is still intentional for the app. If not,
derive the default description from the configured collection/show title or use
a neutral description that matches the current product copy.

Resolution:
Deferred to the revamp. Keep the current default for now, and update generated
video-description copy during the repositioning work.

## Findings 26-30

### 26. Title Treatment Preview CLI Has Personal Defaults

Finding:
`TitleTreatmentPreviewGenerator` is a checked-in executable product, but its
defaults include an absolute personal input path under `/Users/jkfisher/...` and
the caption `Fisher Family Videos`. Its help text advertises those same
defaults.

John's reply:
Fix this later in the upcoming revamp.

Follow-up:
Make the preview tool require an explicit input folder or use a relative/sample
fixture path, and replace personal default title/caption text with neutral
project defaults.

Deliberate or not:
This looks like an intentional local convenience from development, but it is not
aligned with the current no-personal-paths/no-personal-defaults policy for
checked-in tools.

Resolution:
Deferred to the upcoming revamp.

### 27. Manual Inspection Test References Personal Media Paths

Finding:
`ManualStillPipelineInspectionTests` contains hardcoded personal source and
final-export paths under `/Users/jkfisher/...`, then writes a summary containing
those paths when the manual test is enabled.

John's reply:
Align this.

Follow-up:
Replace hardcoded personal paths with environment variables or documented
arguments, and keep generated summaries away from personal absolute paths unless
the user explicitly provides them for that run.

Deliberate or not:
Likely deliberate as a one-off diagnostic harness, but it should be cleaned up
or made parameterized now that policy treats committed personal paths and
diagnostic output more strictly.

Resolution:
Replaced hardcoded personal media paths with explicit environment-variable
inputs for the manual inspection run.

### 28. Metadata Inspection Script Prints Full Directories By Default

Finding:
`scripts/show_metadata.sh` defaults to exiftool fields including
`System:Directory`, and its JSON/ffprobe path can expose full metadata without a
redacted or support-safe mode. That conflicts with the diagnostics/privacy
preference for minimal, redacted-by-default support output.

John's reply:
Align this.

Follow-up:
Decide whether this script is strictly developer-only. If it may be used for
support/debug sharing, make the default output omit or redact full directories
and add an explicit flag for full local paths.

Deliberate or not:
Probably deliberate for local diagnostic usefulness, but not aligned if the
script is treated as user-facing or support-shareable tooling.

Resolution:
Default exiftool output now omits the containing directory. Full local paths
require `--full-paths`, `--all`, or JSON/ffprobe mode.

### 29. Local Build/Test Scripts Prefer Xcode Beta Automatically

Finding:
`scripts/build_app.sh` and `scripts/test.sh` automatically fall back to
`/Applications/Xcode-beta.app/Contents/Developer` when `xcode-select` points at
Command Line Tools. The updated release/build rules avoid machine-specific or
surprising local toolchain choices unless explicit.

John's reply:
Leave this for now.

Follow-up:
Use a stable default such as `/Applications/Xcode.app` when available, and make
beta Xcode selection explicit through `DEVELOPER_DIR` or a clearly named local
override.

Deliberate or not:
This appears deliberately convenient for this machine and past SwiftPM friction,
but it is not ideal as a checked-in default for future/public repo use.

Resolution:
Intentionally left unchanged for now.

### 30. Revamp/Repositioning Decisions Are Not In The Decision Log

Finding:
The review doc now records the planned version reset, app rename/repositioning,
future `com.sidelarklabs.*` identity, and deferred generated-description copy
cleanup, but `docs/DECISIONS.md` does not yet record those meaningful project
decisions.

John's reply:
Update `docs/DECISIONS.md`.

Follow-up:
When policy-alignment documentation work resumes, append a short 2026-07-02
decision-log entry covering the upcoming revamp/repositioning direction and the
deferred identity/copy changes.

Deliberate or not:
Not deliberate; this is a side effect of keeping the current pass limited to
the alignment review doc.

Resolution:
Added a 2026-07-02 decision-log entry covering the revamp/repositioning,
future Sidelark Labs identifiers, version reset direction, and deferred
metadata/copy cleanup.
