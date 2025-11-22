# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Erythrina is a Swift-based game framework for the Playdate handheld gaming console. The project uses Swift's Embedded feature to compile Swift code that runs on the Playdate hardware (ARM Cortex-M7) and simulator.

## Build System

This project uses a custom Makefile-based build system that compiles Swift code for both Playdate device (ARM) and simulator (macOS) targets.

### Building

```bash
# Build the .pdx bundle
make

# Build and run in simulator
./build-and-run.sh

# Clean build artifacts
make clean
```

The build produces `Erythrina.pdx`, a Playdate executable bundle.

### Build Requirements

- Playdate SDK installed (set via `PLAYDATE_SDK_PATH` environment variable or `~/.Playdate/config`)
- Swift toolchain with Embedded Swift support (Swift 6.0+)
- Set `TOOLCHAINS` environment variable or install swift-latest.xctoolchain

## Architecture

### Module Structure

The codebase is organized into three main modules:

1. **CPlaydate** (`Sources/CPlaydate/`): C module providing the Playdate C API
   - Contains C headers and minimal C implementation (`playdate.c`)
   - Exposes the raw Playdate C API to Swift

2. **Playdate** (`Sources/Playdate/`): Swift wrapper around the Playdate API
   - `Playdate.swift`: Core API initialization and `posix_memalign` implementation required by Swift runtime
   - `Display.swift`: Display management (refresh rate, scale, inversion, mosaic effects)
   - `Graphics.swift`: Graphics primitives (bitmaps, geometry, drawing contexts)
   - `System.swift`: System functions (input, time, peripherals, battery)
   - `Sound.swift`: Audio playback
   - `Sprite.swift`: Sprite management

3. **Erythrina** (`Sources/Erythrina/`): Game implementation
   - `Entry.swift`: Entry point with `eventHandler` C function
   - `Game.swift`: Main game loop and rendering logic
   - `Sprite+Extensions.swift`: Sprite utilities

### Entry Point and Game Loop

The Playdate runtime calls `eventHandler()` (in `Entry.swift:8`) with system events. On initialization:
1. `initializePlaydateAPI()` sets up the global Playdate API pointer
2. Display refresh rate is configured
3. `System.setUpdateCallback()` registers the game's update function
4. The `Game.update()` method is called each frame and must return 1 to signal display updates

### Compilation Model

The build compiles Swift twice per target:
1. **Playdate module** is built first (device and simulator variants)
2. **Game module** is built linking against the appropriate Playdate module

Module aliasing is used (`-module-alias Playdate=playdate_device` / `playdate_simulator`) to support both targets from the same source.

### Swift Embedded Constraints

This project uses Embedded Swift, which has restrictions:
- No Objective-C interop
- No standard library reflection
- Limited runtime features
- Manual memory management for C interop
- Whole module optimization required

### Graphics Model

The Playdate display is 400x240 pixels with a 1-bit framebuffer:
- Row stride is 52 bytes (400 pixels / 8 + 2 padding bytes)
- Pixels are MSB-ordered within bytes
- `Frame` struct (in `Game.swift:32`) provides subscript access to individual pixels
- Use `Graphics.getFrame()` for the next frame buffer and `Graphics.getDisplayFrame()` for the current screen

### API Access Pattern

Playdate APIs are accessed through global enums that wrap the C API:
- `Display.*` - display configuration
- `Graphics.*` - drawing operations
- `System.*` - input, time, system info
- `Sound.*` - audio playback
- `Sprite.*` - sprite management

All access the global `playdateAPI` pointer initialized during startup.
