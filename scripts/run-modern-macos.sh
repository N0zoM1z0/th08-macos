#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 1 && ( "$1" == "-h" || "$1" == "--help" ) ]]; then
    echo "usage: $0 /path/to/original-th08-directory"
    exit 0
fi
if [[ $# -ne 1 ]]; then
    echo "usage: $0 /path/to/original-th08-directory" >&2
    exit 2
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
build_dir="${TH08_MACOS_BUILD_DIR:-${repo_dir}/build/modern-macos-arm64}"
binary="${build_dir}/th08-modern.app/Contents/MacOS/th08-modern"
data_dir="$1"

if [[ "$(uname -s)" != "Darwin" || "$(uname -m)" != "arm64" ]]; then
    echo "The native launcher requires an Apple Silicon Mac (Darwin arm64)." >&2
    exit 1
fi
if [[ ! -d "${data_dir}" ]]; then
    echo "TH08 data directory not found: ${data_dir}" >&2
    exit 1
fi
data_dir="$(cd "${data_dir}" && pwd -P)"
for archive in th08.dat thbgm.dat; do
    if [[ ! -f "${data_dir}/${archive}" ]]; then
        echo "Selected data directory does not contain ${archive}: ${data_dir}" >&2
        exit 1
    fi
done
if [[ ! -x "${binary}" ]]; then
    echo "macOS build not found; run scripts/build-modern-macos.sh first." >&2
    exit 1
fi

exec "${binary}" --data-dir "${data_dir}"
