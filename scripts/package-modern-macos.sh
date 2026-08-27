#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
build_dir="${TH08_MACOS_BUILD_DIR:-${repo_dir}/build/modern-macos-arm64}"
bundle="${1:-${build_dir}/th08-modern.app}"
archive="${2:-${repo_dir}/build/th08-modern-macos-arm64.zip}"

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "macOS packaging requires macOS." >&2
    exit 1
fi

"${repo_dir}/scripts/verify-modern-macos.sh" "${bundle}"
mkdir -p "$(dirname "${archive}")"
rm -f "${archive}"
ditto -c -k --sequesterRsrc --keepParent "${bundle}" "${archive}"
shasum -a 256 "${archive}" > "${archive}.sha256"

echo "Packaged development bundle: ${archive}"
