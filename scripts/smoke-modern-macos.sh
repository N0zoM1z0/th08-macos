#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
build_dir="${TH08_MACOS_BUILD_DIR:-${repo_dir}/build/modern-macos-arm64}"
bundle="${1:-${build_dir}/th08-modern.app}"
binary="${bundle}/Contents/MacOS/th08-modern"

if [[ "$(uname -s)" != "Darwin" || "$(uname -m)" != "arm64" ]]; then
    echo "The macOS entry-point smoke test requires an Apple Silicon Mac." >&2
    exit 1
fi
if [[ ! -x "${binary}" ]]; then
    echo "macOS executable not found: ${binary}" >&2
    exit 1
fi

smoke_dir="$(mktemp -d "${TMPDIR:-/tmp}/th08-macos-smoke.XXXXXX")"
cleanup() {
    rm -rf -- "${smoke_dir}"
}
trap cleanup EXIT

set +e
"${binary}" --data-dir "${smoke_dir}" >"${smoke_dir}/output.txt" 2>&1
status=$?
set -e

if [[ ${status} -eq 0 ]]; then
    echo "The no-data smoke test unexpectedly succeeded." >&2
    exit 1
fi
if ! grep -q "selected directory does not contain th08.dat" "${smoke_dir}/output.txt"; then
    echo "The executable did not reach the expected data-directory gate." >&2
    sed -n '1,80p' "${smoke_dir}/output.txt" >&2
    exit 1
fi

echo "macOS entry point and data-directory gate passed."
