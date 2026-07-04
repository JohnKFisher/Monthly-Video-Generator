# Monthly Video Generator

Monthly Video Generator is a local-only macOS app for turning photos and videos
into monthly slideshow movies.

It works with regular folders or Apple Photos, writes Plex-friendly metadata,
and keeps the current HDR export path local to the Mac. The project is part of
Sidelark Labs: https://sidelarklabs.com

## Current Status

This is the final build of the original, tech-heavy version of Monthly Video
Generator. It is fully functional for the workflow it was built for: creating
local monthly videos from folders or Apple Photos. It can be slow and
user-unfriendly, but you are welcome to use it in the meantime.

A friendlier rebuild under a new name is in development for the Mac App Store.
Watch https://sidelarklabs.com for progress updates or to find out how to get
the new app if it is already available.

## Features

- Builds monthly videos from mixed photos and videos.
- Works from either folders or Apple Photos.
- Supports album-based Apple Photos exports, including mixed-month albums.
- Adds title cards, crossfades, captions, and capture-date overlays.
- Queues multiple exports and can pause after the current job.
- Produces Plex-friendly MP4 metadata and chapter markers for the current workflow.
- Uses bundled FFmpeg/ffprobe for packaged HDR exports.

## Distribution

Use the `.dmg` attached to the GitHub Release. The release DMG is built by the
project release workflow, Developer ID signed, notarized by Apple, and stapled
so it should open on other Macs without Gatekeeper workarounds.

Local builds made directly from source may still be ad-hoc signed unless you
provide a Developer ID signing identity.

## More Information

- Current project status: [docs/WHERE_WE_STAND.md](docs/WHERE_WE_STAND.md)
- HDR/colorspace reference: [docs/HDR_COLOR_REFERENCE.md](docs/HDR_COLOR_REFERENCE.md)
- Third-party tooling notes: [docs/THIRD_PARTY.md](docs/THIRD_PARTY.md)
- Attributions: [docs/ATTRIBUTIONS.md](docs/ATTRIBUTIONS.md)
- License: [LICENSE](LICENSE)
