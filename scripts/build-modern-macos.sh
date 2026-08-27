#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
build_dir="${TH08_MACOS_BUILD_DIR:-${repo_dir}/build/modern-macos-arm64}"

if [[ "$(uname -s)" != "Darwin" || "$(uname -m)" != "arm64" ]]; then
    echo "The native build requires an Apple Silicon Mac (Darwin arm64)." >&2
    exit 1
fi

for command_name in cmake ninja pkg-config python3 lipo codesign; do
    if ! command -v "${command_name}" >/dev/null 2>&1; then
        echo "Missing macOS build command: ${command_name}" >&2
        exit 1
    fi
done

cmake -S "${repo_dir}" -B "${build_dir}" -G Ninja \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET="${TH08_MACOS_DEPLOYMENT_TARGET:-11.0}"
cmake --build "${build_dir}" --parallel "${TH08_MACOS_BUILD_JOBS:-3}"

bundle="${build_dir}/th08-modern.app"
"${repo_dir}/scripts/verify-modern-macos.sh" "${bundle}"
codesign --force --sign - --timestamp=none "${bundle}"
codesign --verify --deep --strict "${bundle}"

echo "Built Apple Silicon application: ${bundle}"
