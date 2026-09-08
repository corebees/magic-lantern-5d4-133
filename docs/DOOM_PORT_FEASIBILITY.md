# Doom port feasibility — Canon EOS 5D Mark IV 1.3.3

Updated: 2026-09-08

Status: `RESEARCH / FEASIBILITY ONLY / NO DOOM-SPECIFIC HARDWARE VALIDATION`

## Conclusion

A 5D4 port appears technically plausible because [Doom550D](https://github.com/lauris-nl/doom550d) already implements Doom as a Magic Lantern module. The engine integration, Doom-family IWAD selection, save/configuration handling, game-side logic, sound effects, synthesized music, camera controls, and cleanup provide a reusable starting point.

This is not evidence that Doom currently runs on the 5D4. The released 550D `doom.mo` must never be loaded on another camera or firmware. A 5D4 module must be rebuilt against the exact 5D4.133 core and exported symbol set, and its camera-facing layer must be adapted and tested physically.

## Display geometries: do not conflate

| Layer | Geometry | Meaning |
|---|---:|---|
| Physical LCD panel | approximately `900×600` pixels | Estimate inferred from Canon's 1.62-million-dot RGB, 3:2 specification; not the observed LiveView buffer |
| Canon LiveView YUV surface | `1024×600` | Hardware-observed internal YUV422 surface; spacing `0x12C000 = 1024 × 600 × 2` |
| Magic Lantern overlay coordinates | `720×480` | Logical bitmap/overlay space retained by the current 5D4 implementation |

A plausible presentation path is:

`Doom renderer -> ML 720×480 bitmap/overlay -> Canon compositor -> physical LCD`

Doom550D already targets the classic ML 720×480 environment, including an optional 360×240 render expanded as exact 2×2 pixels. Compatibility with the 5D4 bitmap format, pitch, palette, presentation path, and restoration behavior remains untested. The verified 1024×600 LiveView geometry must not be modified or reinterpreted for Doom.

## Adaptation areas

### Module loading

First build a minimal module against the exact 5D4.133 build and symbols. Do not begin with the released 550D binary.

Initial gate:

`5D4.133 -> load minimal Doom module -> diagnostic display -> clean unload`

Only after that passes should the Doom engine be initialized.

### Display and palette

Determine and verify:

- actual bitmap format and pitch;
- 8-bit VRAM and palette compatibility;
- whether the 720×480 ML logical space can be used directly;
- correct presentation/update method;
- restoration of Canon/ML graphics;
- repeated start/stop safety.

### Input

Map physical 5D4 press and release events for directions, SET, PLAY, MENU, INFO, Q, rear wheel, and suitable run/strafe modifiers. Test held buttons, simultaneous inputs, releases, and event ownership. Current 5D4 GUI/input work is useful prerequisite research but does not validate Doom controls.

### Audio

Audio is deferred. Doom550D expects exports equivalent to:

- `PowerAudioOutput`
- `SetAudioVolumeOut`
- `SetNextASIFDACBuffer`
- `SetSamplingRate`
- `StartASIFDMADAC`
- `StopASIFDMADAC`
- `audio_configure`
- `beep_playing`

The 5D4/DIGIC 6+ path is unvalidated. Missing or incompatible exports require a real backend, not symbol renaming.

### Filesystem and saves

Test WAD reads, directory creation, configuration and save writes, load/overwrite/error paths, repeated operations, and SD integrity. Never commit copyrighted IWADs. Use Freedoom or lawfully obtained compatible data.

### Cleanup and Canon state

A safe checkpoint requires clean task shutdown, input release, framebuffer/palette restoration, eventual audio shutdown, return to ML and Canon shooting state, repeated starts/exits, power-off behavior, and explicit monitoring for freeze or Err 70.

## Proposed development sequence

### DOOM5D4 v0.0.1 research target

- module built for 5D4.133;
- no audio;
- legal/free IWAD;
- simple 320×200 render;
- safest available ML bitmap path;
- minimal controls;
- clean exit.

The first meaningful hardware checkpoint is:

`Games -> Doom -> Start -> stable title screen on physical 5D4 -> clean exit to ML/Canon`

Gameplay/input, held controls, save/load, repeat-cycle testing, sound effects, and music follow only after that.

## Current prerequisite matrix

| Area | Status |
|---|---|
| ML boot on 5D4.133 | `HW VERIFIED` |
| ML GUI | `WORKING`; lifecycle work continues |
| LiveView framebuffer path | `HW VERIFIED` |
| LiveView YUV geometry | `1024×600 / HW VERIFIED` |
| ML overlay geometry | `720×480` in current implementation |
| Zebra geometry baseline | `HW VERIFIED` |
| Global Draw | `PARTIAL` |
| GUI/input mapping | `INVESTIGATING` |
| Doom module loading | `UNTESTED` |
| Doom rendering | `UNTESTED` |
| Doom input | `UNTESTED` |
| Doom audio | `UNTESTED` |

## Risks and acceptance rules

The 5D4 bitmap/palette and DIGIC 6+ audio behavior may differ substantially from the 550D. Raw press/release mappings, clean unload, Canon-state restoration, long-duration operation, and save/write stress are all untested.

A compile or single displayed frame is a `RESEARCH UPDATE`, not a main-branch result. A partial but repeatable physical-camera success may become a `HARDWARE CHECKPOINT`. Promotion to `MAIN MILESTONE` requires clean, reproducible, repeated hardware testing without serious known regressions.

No Doom-specific 5D4 code or hardware result exists at this checkpoint.
