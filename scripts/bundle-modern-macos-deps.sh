#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
build_dir="${TH08_MACOS_BUILD_DIR:-${repo_dir}/build/modern-macos-arm64}"
bundle="${1:-${build_dir}/th08-modern.app}"

if [[ "$(uname -s)" != "Darwin" || "$(uname -m)" != "arm64" ]]; then
    echo "Dependency bundling requires an Apple Silicon Mac." >&2
    exit 1
fi
if [[ ! -d "${bundle}" ]]; then
    echo "macOS application bundle not found: ${bundle}" >&2
    exit 1
fi

dependency_dirs=()
for module in sdl2 SDL2_image SDL2_ttf fontconfig; do
    libdir="$(pkg-config --variable=libdir "${module}")"
    if [[ -n "${libdir}" ]]; then
        dependency_dirs+=("${libdir}")
    fi
done
if command -v brew >/dev/null 2>&1; then
    dependency_dirs+=("$(brew --prefix)/lib")
fi

dependency_path="$(IFS=';'; echo "${dependency_dirs[*]}")"
cmake \
    "-DTH08_MACOS_BUNDLE=${bundle}" \
    "-DTH08_MACOS_DEPENDENCY_DIRS=${dependency_path}" \
    -P "${repo_dir}/cmake/fixup-macos-bundle.cmake"

echo "Embedded non-system runtime dependencies in: ${bundle}"
