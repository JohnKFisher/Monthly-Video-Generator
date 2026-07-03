# Attributions

This file is the machine-readable attribution source for redistributed third-party
components and bundled media/assets.

```yaml
schema: sidelark-attributions-v1
project: Monthly Video Generator
entries:
  - id: ffmpeg-bundle
    name: FFmpeg and FFprobe
    type: bundled-binary
    purpose: HDR/media export and source probing
    copyright: Copyright (c) FFmpeg developers and linked library authors
    upstream_project_url: https://ffmpeg.org/
    bundle_source:
      name: OSXExperts.NET static macOS builds
      url: https://www.osxexperts.net/
    license:
      status: gpl-enabled-needs-final-redistribution-audit
      notes: Bundled binaries report GPL-enabled configurations, and the x64
        slice reports --enable-version3. Treat public packaged redistribution
        as requiring GPL-compatible FFmpeg notices/source-offer handling until
        the exact binary distribution and linked-library obligations are audited.
    attribution_required: true
    redistribution_notes: Preserve FFmpeg notices and satisfy the applicable GPL
      and linked-library obligations before distributing packaged builds.
    provenance_file: third_party/ffmpeg/PROVENANCE.txt
    packaged_location: Monthly Video Generator.app/Contents/Resources/FFmpeg/
    repo_locations:
      - third_party/ffmpeg/darwin-arm64/ffmpeg
      - third_party/ffmpeg/darwin-arm64/ffprobe
      - third_party/ffmpeg/darwin-x64/ffmpeg
      - third_party/ffmpeg/darwin-x64/ffprobe
    artifacts:
      - name: ffmpeg
        architecture: arm64
        reported_version: "8.1"
        source_url: https://www.osxexperts.net/ffmpeg81arm.zip
        sha256: 9a08d61f9328e8164ba560ee7a79958e357307fcfeea6fe626b7d66cdc287028
      - name: ffmpeg
        architecture: x86_64
        reported_version: "8.0"
        source_url: https://www.osxexperts.net/ffmpeg80intel.zip
        sha256: df3f1e3facdc1ae0ad0bd898cdfb072fbc9641bf47b11f172844525a05db8d11
      - name: ffprobe
        architecture: arm64
        reported_version: "8.1"
        source_url: https://www.osxexperts.net/ffprobe81arm.zip
        sha256: aab17ac7379c1178aaf400c3ef36cdb67db0b75b1a23eeef2cb9f658be8844e6
      - name: ffprobe
        architecture: x86_64
        reported_version: "8.0"
        source_url: https://www.osxexperts.net/ffprobe80intel.zip
        sha256: 5228e651e2bd67bb55819b27f6138351587b16d2b87446007bf35b7cf930d891

  - id: app-header-icon
    name: App header icon
    type: bundled-image
    purpose: App UI iconography
    source: Generated locally by scripts/generate_app_icon.swift
    license:
      status: project-owned
    attribution_required: false
    repo_locations:
      - Sources/App/Resources/AppHeaderIcon.png
```
