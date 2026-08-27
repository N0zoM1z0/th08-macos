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
extra_libs=()
for module in sdl2 SDL2_image SDL2_ttf fontconfig; do
    libdir="$(pkg-config --variable=libdir "${module}")"
    if [[ -n "${libdir}" ]]; then
        dependency_dirs+=("${libdir}")
    fi
done
if command -v brew >/dev/null 2>&1; then
    dependency_dirs+=("$(brew --prefix)/lib")

    # Current Homebrew `sdl2` is sdl2-compat. It dlopens SDL3 from its
    # constructor, so this dependency is intentionally invisible to otool and
    # must be supplied to BundleUtilities explicitly.
    sdl3_dylib="$(brew --prefix sdl3)/lib/libSDL3.dylib"
    if [[ -f "${sdl3_dylib}" ]]; then
        extra_libs+=("${sdl3_dylib}")
        dependency_dirs+=("$(dirname "${sdl3_dylib}")")
    fi
fi

dependency_path="$(IFS=';'; echo "${dependency_dirs[*]}")"
extra_lib_path="$(IFS=';'; echo "${extra_libs[*]}")"
cmake \
    "-DTH08_MACOS_BUNDLE=${bundle}" \
    "-DTH08_MACOS_DEPENDENCY_DIRS=${dependency_path}" \
    "-DTH08_MACOS_EXTRA_LIBS=${extra_lib_path}" \
    -P "${repo_dir}/cmake/fixup-macos-bundle.cmake"

if (( ${#extra_libs[@]} != 0 )) && [[ ! -f "${bundle}/Contents/Frameworks/libSDL3.dylib" ]]; then
    echo "sdl2-compat's dynamically loaded SDL3 library was not embedded." >&2
    exit 1
fi

echo "Embedded non-system runtime dependencies in: ${bundle}"
