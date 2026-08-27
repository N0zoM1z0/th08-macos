# Native Apple Silicon macOS port

## Status: bring-up in progress

The repository now has an arm64/LP64 source gate, a native `.app` target, and
an Apple Silicon GitHub Actions build. The application reuses the SDL2 audio,
input, and window compatibility layer from the Linux port and initially maps
the D3D8 calls to macOS's OpenGL compatibility framework.

This is not a playable release yet. The authored sources compile for AArch64,
but the first CI bundle still needs real startup and gameplay validation. The
OpenGL bridge is deliberately a bring-up backend: Apple deprecated OpenGL in
macOS 10.14, so the durable renderer should reuse the Web port's batching
model behind a Metal implementation.

## Build on an Apple Silicon Mac

The one-command developer path installs the Homebrew dependencies, builds,
and starts TH08 against a legally obtained data directory:

```bash
scripts/setup-modern-macos.sh "/path/to/original/TH08 directory"
```

The directory must contain both `th08.dat` and `thbgm.dat`. Those copyrighted
archives are not part of this repository or its CI artifact.

For incremental work:

```bash
scripts/build-modern-macos.sh
scripts/run-modern-macos.sh "/path/to/original/TH08 directory"
```

The application bundle is written to:

```text
build/modern-macos-arm64/th08-modern.app
```

The build embeds its non-system Homebrew dylibs and is ad-hoc signed. It is not
notarized and does not yet have a stable player-facing distribution contract.

## Build boundaries

- `scripts/build-macos-arm64-probe.sh` compiles every authored translation
  unit for arm64 without requiring SDL or linking a program. On Linux it uses
  `aarch64-linux-gnu-g++`; on Apple Silicon it uses the native Apple compiler.
- `scripts/build-modern-macos.sh` links the SDL2/OpenGL `.app` and verifies the
  Mach-O architecture, bundle identifier, and embedded runtime dependencies.
- `scripts/smoke-modern-macos.sh` launches the native entry point without game
  data and verifies that it reaches the expected `--data-dir` rejection path.
- `.github/workflows/macos-arm64.yml` runs both gates on GitHub's `macos-15`
  Apple Silicon runner and uploads a short-lived development artifact.

The 32-bit retail file formats remain fixed-width. The modern 64-bit lane
expands file offsets and callback indices into native pointers at load time;
those conversions must never be merged into the exact VC7 build branch.

## Current risks

- Startup and rendering have not yet been exercised on a real Apple Silicon
  desktop with the legal DAT archives.
- The bundle embeds Homebrew SDL2, SDL2_image, SDL2_ttf, Fontconfig, and their
  non-system dependencies. It is still a developer build until tested outside
  the CI image and notarized for player-facing distribution.
- OpenGL is deprecated on macOS and is only the shortest path to the first
  frame. Metal is the intended long-term renderer.
- Native score/config/replay I/O needs continued LP64 format testing. Replay
  headers and SHT callback tables already have explicit fixed-width readers,
  but the remaining binary formats still need audit and fixtures.

Follow the shared rules in [Playable reconstruction ports](PORTING.md): do not
bundle the original executable, DAT archives, extracted retail assets, score
files, or replays.
