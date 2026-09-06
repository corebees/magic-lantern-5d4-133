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
| ML GUI | `WORKING` | Opens and is usable, but is not fully stabilized |
| Zebra refresh/lag | `INVESTIGATING` | Geometry must remain based on TEST124 |
| Global Draw | `PARTIAL` | Shared overlay behavior is still being stabilized |
| DELETE mapping/lifecycle | `INVESTIGATING` | Electronic Level entry has a `HW TESTED` partial checkpoint (TEST263N-C); the overall lifecycle remains unresolved |
| RTC/date-time corruption | `OPEN` | Seen at ML boot |
| Histogram | `UNVERIFIED` | Do not claim working |
| Focus Peaking | `UNVERIFIED` | Do not claim working |
| Waveform | `UNVERIFIED` | Do not claim working |

## Current limitations

There is no claim of release stability, complete feature coverage, or safe everyday use. Canon firmware, dumps, and proprietary material are outside the repository. Recent fake-Q, no-host, static-curtain, and LiveView GUI experiments remain research evidence rather than verified fixes.


## Electronic Level entry checkpoint — TEST263N-C

Status: `HW TESTED / PARTIAL` on a physical Canon EOS 5D Mark IV running firmware 1.3.3.

The tested sequence prearms a transparent dedicated XIMR layer1 while the Electronic Level dialog is stable. A second DELETE changes the already-active layer to opaque black, emits the hidden Q transition, lets Canon settle in PLAY underneath, redraws and publishes the ML menu, and only then blanks/disables the curtain.

Observed result: `Electronic Level -> black curtain -> ML`. The Canon Q and Menu/PLAY flashes seen in earlier tests were not visible, and the final TEST263N-C run reported no freeze or Err 70.

This is not a general GUI fix. It currently requires two DELETE presses, deliberately shows a black curtain, is specific to `DlgOlcLevel`, and has not completed a full regression matrix. Display-off/no-host and LiveView remain separate problems.

Source provenance is incomplete: the available TEST263N-C handoff records the N-B `src/menu.c` SHA-256 as `3e2587aee2f1d72067c6f62c49ce4c226766bcb416ae582c5db83dfb8d9d468c`, but the complete final N-C source file after the declaration-order build fix is not currently preserved in this repository. Do not reconstruct or claim source reproducibility until that exact file is acquired and diffed.
