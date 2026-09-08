# Canon EOS 5D Mark IV 1.3.3 port status

Updated: 2026-09-06

## Scope and provenance

This repository documents integration work performed on top of upstream Magic Lantern and earlier 5D Mark IV porting research. A result is attributed to this project only when its evidence comes from our source change, static analysis, or hardware test. Experimental test builds are not treated as upstream changes or confirmed fixes.

## Status vocabulary

| Status | Meaning |
|---|---|
| `VERIFIED` | Evidence has been reviewed and the finding is confirmed |
| `HW TESTED` | Observed on a physical EOS 5D Mark IV running firmware 1.3.3 |
| `WORKING` | The function performs its core purpose; it may still have limitations |
| `PARTIAL` | Only part of the path or behavior works |
| `INVESTIGATING` | Active diagnosis; no accepted resolution yet |
| `OPEN` | Confirmed unresolved problem |
| `TODO` | Planned work without validation |
| `UNVERIFIED` | No accepted hardware evidence yet |

## Hardware-verified baselines

| Build/baseline | Result | Status |
|---|---|---|
| 5D4.133 boot-capable build | Magic Lantern starts on EOS 5D Mark IV firmware 1.3.3 | `VERIFIED / HW TESTED` |
| LiveView DispVram path | Active/current image located through the DispVram control block, at the observed `+0x78` field | `VERIFIED / HW TESTED` |
| LiveView geometry baseline | 1024×600 display geometry | `VERIFIED / HW TESTED` |
| Zebra `TEST124` baseline | Correct Zebra geometry; retain as frozen geometry reference | `VERIFIED / HW TESTED` |
| Real ML Zebra path | Actual Magic Lantern Zebra renders on camera | `WORKING / HW TESTED` |

The source commit corresponding to each redistributable build must be added when source history is imported. Binary artifacts are not committed here.

## Known validated artifact metadata

These values identify previously tested local artifacts; they do not make the binaries redistributable.

| Artifact | Size | SHA-256 | Note |
|---|---:|---|---|
| `autoexec.bin` | 212,960 bytes | `8ecf6c6d…` | Historical hardware-test artifact; full digest not preserved in current notes |
| `magiclantern.bin` | 209,936 bytes | `ef37eb9b…` | Historical hardware-test artifact; full digest not preserved in current notes |
| `autoexec.bin` | 217,472 bytes | `ede21098ca03d4204e7c0779191faf8d4963c13b2505d99dcbb0a15c2f58b4b7` | Later SD-tested artifact |

The incomplete hashes are identifiers only and must not be used for cryptographic verification.

## Current matrix

| Area | Status | Qualification |
|---|---|---|
| ML GUI | `WORKING / HW TESTED` | Electronic Level and LiveView entry/exit paths are hardware-verified; other GUI hosts remain separate |
| Zebra refresh/lag | `INVESTIGATING` | Geometry must remain based on TEST124 |
| Global Draw | `PARTIAL` | Shared overlay behavior is still being stabilized |
| DELETE mapping/lifecycle | `WORKING / HW TESTED` | M1-RC1: single-DELETE Electronic Level entry and root/submenu return passed hardware regression; other GUI hosts remain separate |
| RTC/date-time corruption | `OPEN` | Seen at ML boot |
| Histogram | `UNVERIFIED` | Do not claim working |
| Focus Peaking | `UNVERIFIED` | Do not claim working |
| Waveform | `UNVERIFIED` | Do not claim working |

## Current limitations

There is no claim of release stability, complete feature coverage, or safe everyday use. Canon firmware, dumps, and proprietary material are outside the repository. LiveView menu entry now has a hardware-verified research checkpoint. Normal shooting, Quick Control display-state integration, display-off, Auto-off/Wake, and general GUI cleanup remain outside this checkpoint.


## Electronic Level entry checkpoint — TEST263N-C

Status: `HW TESTED / PARTIAL` on a physical Canon EOS 5D Mark IV running firmware 1.3.3.

The tested sequence prearms a transparent dedicated XIMR layer1 while the Electronic Level dialog is stable. A second DELETE changes the already-active layer to opaque black, emits the hidden Q transition, lets Canon settle in PLAY underneath, redraws and publishes the ML menu, and only then blanks/disables the curtain.

Observed result: `Electronic Level -> black curtain -> ML`. The Canon Q and Menu/PLAY flashes seen in earlier tests were not visible, and the final TEST263N-C run reported no freeze or Err 70.

This is not a general GUI fix. It currently requires two DELETE presses, deliberately shows a black curtain, is specific to `DlgOlcLevel`, and has not completed a full regression matrix. Display-off/no-host and LiveView remain separate problems.

The exact final TEST263N-C source has now been acquired. Its `src/menu.c` SHA-256 is `e15b62ca710d9b7e6415fd3eed6b99992253815c0900d5b90f84436ee8b52c6e`. The published research patch contains 372 additions relative to the TEST263K/J `src/menu.c` baseline SHA-256 `2cef89a15d77302b321de3888a158fd2891c36286da86f03681e0d7ae30cb8dd`. Diagnostic TEST263 names and instrumentation remain intentionally present; this is reproducible research evidence, not cleaned code for `main`.


## Electronic Level milestone — M1-RC1

Status: `HARDWARE VERIFIED / M1-RC1` on physical Canon EOS 5D Mark IV firmware 1.3.3.

Validated sequence: `Electronic Level -> single DELETE -> frozen Electronic Level frame -> ML`.

M1-RC1 automatically prearms transparent XIMR layer1 while the level is stable. DELETE freezes the current level frame; Canon Q and backing-GUI transitions occur underneath while ML remains closed. The curtain is removed only after the final redraw flood and explicit ML publication.

Regression PASS covered repeated entry, submenu DELETE to root, root DELETE to the level, leaving the level without opening ML, and physical Q/Q followed by level entry. No Canon Q/Menu frame, black transition, freeze, or Err 70 was observed.

Final `src/menu.c`: `f0d4c8642d611fc3d4e12d58e7e17d0ed8327605c3c178944c345650192d8011`. Hardware-tested `autoexec.bin`: `f68867942b980cfbbcdcd22caef499f83df8a6bde31670bcf853e13485d6332d` (not committed). Pre-cleanup HW-pass source: `d1f7c56a5c3676889083baaeb08bfe0580cd52ba167ac5eed8e7dc90c2fe17f2`.

Scope excludes Auto-off/Wake, display-off/no-host behavior, and LiveView. TEST263N-C remains the immediate research predecessor.


## LiveView ML menu milestone — TESTLV15D-B

Status: `HARDWARE VERIFIED / RESEARCH CHECKPOINT` on physical Canon EOS 5D Mark IV firmware 1.3.3.

Validated sequence: `LiveView -> DELETE -> frozen Canon GUI frame -> ML over moving LiveView`. Canon XIMR layer0 is hidden while the menu is published on dedicated layer1. Hidden Quick Control mode `0x29` owns MAIN and REAR wheel input, with a same-state refresh approximately every 2000 ms to prevent the native roughly 10-second timeout.

Hardware regression confirmed clean entry and exit, moving LiveView beneath ML, one ML movement per MAIN detent, MAIN/REAR isolation from Tv/Av and the physical diaphragm, restoration of shooting-wheel ownership after exit, no visible Canon Q flash, and no observed freeze or Err 70.

Exact incremental source patch: M1-RC1 `src/menu.c` SHA-256 `f0d4c8642d611fc3d4e12d58e7e17d0ed8327605c3c178944c345650192d8011` to LiveView result `6408dad4d4312d8b97a2a19f2b5821774aaa795fc8346a80bbd27e8d059e9fc4`. Hardware-tested `autoexec.bin`: `347738d8b3a7bcec6abdb4c9b8d23167586b45ccd17cdf0b8fe89da98091d4c4` (not committed).

TESTLV instrumentation remains intentionally present. Normal shooting, the INFO-cycle Quick Control display, display-off, Auto-off/Wake, and LiveView cleanup are separate follow-up work.
