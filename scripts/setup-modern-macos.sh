#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 1 && ( "$1" == "-h" || "$1" == "--help" ) ]]; then
    echo "usage: $0 /path/to/original-th08-directory"
    echo "Installs Homebrew dependencies, builds, and runs the Apple Silicon port."
    exit 0
fi
if [[ $# -ne 1 ]]; then
    echo "usage: $0 /path/to/original-th08-directory" >&2
    exit 2
fi
if [[ "$(uname -s)" != "Darwin" || "$(uname -m)" != "arm64" ]]; then
    echo "Setup requires an Apple Silicon Mac (Darwin arm64)." >&2
    exit 1
fi
if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is required: https://brew.sh/" >&2
    exit 1
fi

brew install cmake ninja pkg-config sdl2 sdl2_image sdl2_ttf fontconfig

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"${script_dir}/build-modern-macos.sh"
exec "${script_dir}/run-modern-macos.sh" "$1"
