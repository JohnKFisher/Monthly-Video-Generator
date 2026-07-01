#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

configure_developer_dir() {
  if [[ -n "${DEVELOPER_DIR:-}" ]]; then
    return
  fi

  local selected_developer_dir
  selected_developer_dir="$(xcode-select -p 2>/dev/null || true)"
  case "$selected_developer_dir" in
    *CommandLineTools*)
      ;;
    *)
      return
      ;;
  esac

  local candidate
  for candidate in \
    "/Applications/Xcode.app/Contents/Developer" \
    "/Applications/Xcode-beta.app/Contents/Developer"
  do
    if [[ -d "$candidate" ]]; then
      export DEVELOPER_DIR="$candidate"
      echo "Using DEVELOPER_DIR=$DEVELOPER_DIR because xcode-select points at Command Line Tools."
      return
    fi
  done

  echo "Error: xcode-select points at Command Line Tools, but this project requires a full Xcode developer directory." >&2
  echo "Install Xcode or set DEVELOPER_DIR to a full Xcode app before running this script." >&2
  exit 1
}

refuse_codex_sandbox() {
  if [[ -z "${CODEX_SANDBOX:-}" ]]; then
    return
  fi

  cat >&2 <<'EOF'
Error: ./scripts/test.sh is running inside the Codex seatbelt sandbox.

SwiftPM/SwiftUI macro plugin startup fails there with sandbox-exec/plugin-server
errors in this repo. In Codex, rerun this exact command with
sandbox_permissions=require_escalated instead of trying the sandboxed path first.
EOF
  exit 86
}

cleanup() {
  if [[ -n "${SCRATCH_PATH:-}" && -d "$SCRATCH_PATH" ]]; then
    rm -rf "$SCRATCH_PATH"
  fi
  if [[ -n "${TEST_HOME_DIR:-}" && -d "$TEST_HOME_DIR" ]]; then
    rm -rf "$TEST_HOME_DIR"
  fi
}

trap cleanup EXIT
refuse_codex_sandbox
configure_developer_dir

SCRATCH_PATH="${SWIFT_TEST_SCRATCH_PATH:-$(mktemp -d "${TMPDIR:-/tmp}/monthly-video-generator-swiftpm.XXXXXX")}"
TEST_HOME_DIR="${SWIFT_TEST_HOME_DIR:-$(mktemp -d "${TMPDIR:-/tmp}/monthly-video-generator-home.XXXXXX")}"
export HOME="$TEST_HOME_DIR"
SWIFT_TEST_DISABLE_SANDBOX="${SWIFT_TEST_DISABLE_SANDBOX:-1}"
echo "Running swift test with scratch path: $SCRATCH_PATH"
echo "Using isolated HOME: $HOME"

SWIFT_TEST_ARGS=(--scratch-path "$SCRATCH_PATH")
if [[ "$SWIFT_TEST_DISABLE_SANDBOX" != "0" ]]; then
  SWIFT_TEST_ARGS+=(--disable-sandbox)
  echo "SwiftPM subprocess sandbox: disabled"
else
  echo "SwiftPM subprocess sandbox: enabled"
fi

swift test "${SWIFT_TEST_ARGS[@]}" "$@"
