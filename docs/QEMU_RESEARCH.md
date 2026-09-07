# 5D4.133 QEMU research

Updated: 2026-09-07

Status: `RESEARCH / QEMU VERIFIED IN PART / NOT HARDWARE VALIDATION`

## Scope

This record summarizes the QEMU04–QEMU38ZZQ investigation without publishing Canon firmware, ROM-derived bulk output, raw execution logs, or private filesystem data. “QEMU verified” means reproduced in the emulator; it is not a physical-camera safety or functionality claim.

## Progression

| Phase | Confirmed result | Remaining limitation |
|---|---|---|
| QEMU04–06 | FW 1.3.3 boots far enough to detect a 4 GB FAT32 card; DCF seeding does not remove `EstimatedSize.c:1473` | Storage/DCF zero excluded as root cause |
| QEMU07B–12 | Assertion originates from malformed `PROP_VIDEO_MODE` field 2 (`81`) copied through RscMgr | Producer is generic MPU fallback |
| QEMU13–16 | Runtime differential `{0,1,81} -> {0,0,2997}` causally clears assertion and reaches PrepareCapture | Diagnostic, not a proper 5D4 MPU spell implementation |
| QEMU16B–23 | 720×480 framebuffer remains blank because bitmap/image VRAM and GUI/XIMR lifecycle never initialize | Renderer is not the primary failure |
| QEMU24D–27 | GUI task creator and unique call chain identified; GUI initialization path is not entered | Blocker lies earlier in startup |
| QEMU28–36 | Six-stage sequencer, RAM callback table, dispatcher, `NotifyComplete`, and missing stage-3 completion reconstructed | Required completion paths absent |
| QEMU37A–Z | H3 reaches `FE0E236A`, enters `take_semaphore`, and does not return | Missing subsystem completion blocks semaphore |
| QEMU38U | 5D4 MEMDIV base/range mismatch identified and fixed in qemu-eos | Other runtime differentials remain |
| QEMU38V/WR/ZB | MEMDIV/SHM path and OmarSysInit return confirmed end-to-end under controlled differentials | Not a clean native boot |
| QEMU38ZZQ | Experimental `D20F0110=3 -> IRQ 0x9C` MOCom/Omar completion model added | Requires validation; intentionally incomplete |

## Strong findings

- `EstimatedSize.c:1473` is causally tied to malformed generic-MPU `PROP_VIDEO_MODE` data.
- Blank display occurs before GUI/XIMR initialization; importing an existing framebuffer is not the explanation.
- Startup uses a six-stage sequencer backed by a RAM callback table.
- The first H3 blocker is a non-returning semaphore wait in `FE0E236A`.
- Firmware uses MEMDIV from `0xD9000A20`, outside the old qemu-eos range. Adding the range and offset `0x0A24` clears the MEMDIV/SHM blocker causally.
- `FE34D2A6` is not a blocker after MEMDIV correction.

## Corrections and rejected hypotheses

- DCF number zero is not the EstimatedSize cause.
- Main-firmware presentation addresses were corrected from `FC...` to the `FE...` runtime alias.
- `FE434B7A` is shared; a hit alone does not prove Omar execution.
- Earlier negatives inside Omar followed from OmarSysInit not being entered.
- The six-stage sequencer uses a RAM table, not the initially hypothesized direct ROM table.

## Reproducibility boundary

The committed qemu-eos patch reproduces source changes only. QEMU38ZB also depended on controlled runtime changes to `PROP_VIDEO_MODE` and the Omar wait. This is not a complete 5D4 emulator boot fix.

## Excluded evidence

Raw run/GDB/verification transcripts remain private because they include ROM names/hashes, personal paths, large debug output, and ROM-derived disassembly. They informed this summary but are not committed verbatim.

## Next tests

1. Validate or reject QEMU38ZZQ in a clean process.
2. Replace runtime `PROP_VIDEO_MODE` differential with a proper 5D4 MPU spell/model.
3. Remove Omar wait intervention and confirm native semaphore completion.
4. Continue through GUI/XIMR initialization and capture a nonblank display.
