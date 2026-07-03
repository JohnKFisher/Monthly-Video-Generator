# Monthly Video Generator

Monthly Video Generator is a local-only macOS app for turning photos and videos
into monthly slideshow movies.

It works with regular folders or Apple Photos, writes Plex-friendly metadata,
and keeps the current HDR export path local to the Mac. The project is part of
Sidelark Labs: https://sidelarklabs.com

## Current Status

The current app is usable for the workflow it was built for. A larger
revamp/repositioning is planned next, including version reset work and
Sidelark Labs identity cleanup.

## Features

- Builds monthly videos from mixed photos and videos.
- Works from either folders or Apple Photos.
- Supports album-based Apple Photos exports, including mixed-month albums.
- Adds title cards, crossfades, captions, and capture-date overlays.
- Queues multiple exports and can pause after the current job.
- Produces Plex-friendly MP4 metadata and chapter markers for the current workflow.
- Uses bundled FFmpeg/ffprobe for packaged HDR exports.

## Distribution

Local packaged builds are ad-hoc signed by default and are not notarized. macOS
may require Finder Open, Control-click Open, or Privacy & Security approval for
non-notarized local builds.

Public distribution should use an explicitly reviewed signing/notarization path
and must not overwrite already-published release artifacts.

## Build From Source

Requirements:

- macOS 15-class environment.
- Full Xcode developer directory, not just Command Line Tools.
- Enough free disk space for temporary render intermediates.

Build the package:

```bash
swift build
```

Run tests:

```bash
./scripts/test.sh
```

Run the app from source:

```bash
swift run MonthlyVideoGeneratorApp
```

Build a packaged `.app` bundle:

```bash
./scripts/build_app.sh
```

Create a `.dmg` from that app bundle:

```bash
./scripts/create_dmg.sh
```

The packaged app build uses checked-in `VERSION` and `BUILD_NUMBER` files as
the app version/build source of truth. The packaging scripts do not mutate them.

## More Information

- Current project status: [docs/WHERE_WE_STAND.md](docs/WHERE_WE_STAND.md)
- HDR/colorspace reference: [docs/HDR_COLOR_REFERENCE.md](docs/HDR_COLOR_REFERENCE.md)
- Third-party tooling notes: [docs/THIRD_PARTY.md](docs/THIRD_PARTY.md)
- Attributions: [docs/ATTRIBUTIONS.md](docs/ATTRIBUTIONS.md)
- License: [LICENSE](LICENSE)
