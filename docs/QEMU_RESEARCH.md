# 5D4.133 QEMU research

Updated: 2026-09-10

Status: `RESEARCH / QEMU VERIFIED IN PART / NOT HARDWARE VALIDATION`

## Scope

This record summarizes the QEMU04–QEMU40EN investigation without publishing Canon firmware, ROM-derived bulk output, raw execution logs, or private filesystem data. “QEMU verified” means reproduced in the emulator; it is not a physical-camera safety or functionality claim.

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
| QEMU40DK | Added 5D4 D200 pending/ack diagnostic around `D2000208`, `D2000400`, and IRQ `0x8D` | No preserved test report; unverified |
| QEMU40EA | Added recovered 5D4 JpCore ranges at `D0100000`, `D0110000`, and `D0120000` | No preserved test report; unverified |
| QEMU40EN | Added narrow ResManagPostS TX0/RX1 reply model using IRQs `0x0D` and `0x1C` | Source-preservation checkpoint; not hardware validation |
| Post-QEMU40EN | Progressed through ResManagPostS continuation, TX4/RX5 dispatch, startup stage 3, PCommMem ownership, RTC/TimeCodeMaster, Omar event 10, APROC, D200/Postman TX2, Zico/MZRM, and LvGain | Emulator/reverse-engineering results only |
| QEMU40NR | Canon startup reaches `GUI_Initialize`, `GuiMainTask`, `GuiInitializeGraphics`, and `Pana_Init` | Panasonic RESET_COMPLETE remains blocked |
| Panasonic CH2 | Command `0x3C` decoded as `READ 0x70:0x02 len=2`; Canon compares requested length with `D6050010[31:24]` | QEMU40NR one-byte model was insufficient |
| QEMU40OV | Dynamic multi-byte CH2 RX accounting passes the two-byte transport frontier while preserving one-byte reads | Payload remains synthetic; not a final device model |
| QEMU40OX-A | `reg08` bit 3 is mapped to the Panasonic/display hotplug prerequisite and provides a runtime witness | Does not complete `Pana_Init` |
| QEMU40OZ-B / PAA-R3 | One-shot `0x03` and a 64-read synthetic burst were both insufficient | Simple repetition is not the missing semantic |
| EDID preread frontier | Payload `0x03` leads to write `0x98 = 0x81`; execution advances from `wait143` to `line151` | Exact Panasonic/EDID response semantics remain unknown |
| PAD-AB | Canon naturally issues two CH2 reads from slave `0x7C`: offsets `0x00` and `0x40`, 64 bytes each | Existing model returns zero bytes |
| PAD-AC | RAM-only checksum-valid synthetic EDID causes checksum pass, sink status 3, and `Pana_Init End : EDID = 3` | Causal witness only; not a transport model |
| PAD-AD | Same synthetic EDID delivered through Canon's natural CH2 slave-`0x7C` receive path; both 64-byte reads complete and Canon reports EDID success | Experimental payload and verbose diagnostics remain |

## Strong findings

- `EstimatedSize.c:1473` is causally tied to malformed generic-MPU `PROP_VIDEO_MODE` data.
- Blank display occurs before GUI/XIMR initialization; importing an existing framebuffer is not the explanation.
- Startup uses a six-stage sequencer backed by a RAM callback table.
- The first H3 blocker is a non-returning semaphore wait in `FE0E236A`.
- Firmware uses MEMDIV from `0xD9000A20`, outside the old qemu-eos range. Adding the range and offset `0x0A24` clears the MEMDIV/SHM blocker causally.
- `FE34D2A6` is not a blocker after MEMDIV correction.
- Canon startup now reaches Panasonic/display initialization in QEMU.
- Panasonic command `0x3C` requests two bytes from `0x70:0x02`.
- The Canon CH2 receive path treats `D6050010[31:24]` as the actual byte count and rejects a count that differs from the requested length.
- QEMU40NR reports `0x01000000`, so its one-byte receive model is deterministically incompatible with command `0x3C`.
- QEMU40OV implements and runtime-validates multi-byte receive accounting sufficiently to pass the two-byte CH2 transport blocker without globally forcing all reads to length 2.
- The next causal dependency is the Panasonic hotplug/EDID preread path: `reg08` bit 3 is a runtime witness, and payload `0x03` causes `0x98 = 0x81`.
- Neither one `0x03` response nor a synthetic 64-read burst completes initialization; the current execution frontier is `wait143 -> line151`.

## Corrections and rejected hypotheses

- DCF number zero is not the EstimatedSize cause.
- Main-firmware presentation addresses were corrected from `FC...` to the `FE...` runtime alias.
- `FE434B7A` is shared; a hit alone does not prove Omar execution.
- Earlier negatives inside Omar followed from OmarSysInit not being entered.
- The six-stage sequencer uses a RAM table, not the initially hypothesized direct ROM table.

## Reproducibility boundary

The committed qemu-eos patches reproduce source changes only. They are complete alternatives based on the same upstream commit and must not be stacked. QEMU38ZB also depended on controlled runtime changes to `PROP_VIDEO_MODE` and the Omar wait. This is not a complete 5D4 emulator boot fix.

## Excluded evidence

Raw run/GDB/verification transcripts remain private because they include ROM names/hashes, personal paths, large debug output, and ROM-derived disassembly. They informed this summary but are not committed verbatim.

## Current frontier and next tests

QEMU40OV passes the CH2 multi-byte receive-count blocker. The current causal frontier has moved into the Panasonic hotplug/EDID preread sequence.

Confirmed progression:

1. `reg08` bit 3 maps to the hotplug prerequisite.
2. QEMU40OX-A provides the corresponding runtime witness.
3. Synthetic payload `0x03` leads to `0x98 = 0x81`.
4. Execution advances from `wait143` to `line151`.
5. QEMU40OZ-B proves that a one-shot `0x03` response is insufficient.
6. QEMU40PAA-R3 proves that merely extending the same synthetic response to 64 reads is also insufficient.

Next, recover the real response/state progression expected by the EDID preread path. Preserve QEMU40OV multi-byte accounting and already-working one-byte reads. Do not treat synthetic `0x08` or `0x03` as known Panasonic semantics.

QEMU40PAA and older probes remain temporary experimental instrumentation, not a final qemu-eos implementation.

## PAD-AD synthetic EDID checkpoint

Bounded reverse engineering identifies `FE21154A` as the 128-byte EDID descriptor creator, using the destination registered through B6EC (`0x32360`) and slave `0x7C`. `FE1FD790` splits the acquisition into two natural reads: offset `0x00`, length 64, destination `0x32360`; then offset `0x40`, length 64, destination `0x323A0`.

PAD-AD moves the checksum-valid PAD-AC witness from GDB RAM injection into the natural CH2 receive path. Canon itself receives both blocks and reaches `Get EDID Success` and `Pana_Init End : EDID = 3`, then advances through Movie/VRAM/HDR, TouchPanel, and GUI initialization.

The published incremental source patch transforms experimental `hw/eos/eos.c` SHA-256 `809da93ab66fa1bfde796950126b839627e9b95b7f90e4d54135da5dd4fa166e` into `31f5aa4220c415a8df3c6eddcfd119a17b27815964037f5cf6770a6d3c4e3a1d`. It retains PAD-AD byte logging for exact reproducibility and is not an upstream-ready patch.

Current later blockers include TouchPanel semaphore error 9/boot-wakeup failure and recurring Omar no-response reports. Global startup completion remains unproven.

## QEMU40 source checkpoint

The current `hw/eos/eos.c` diff is preserved as `0002-qemu-eos-5D4-QEMU40-current.patch`, SHA-256 `b93a6e4c76fb69cae69401dacc2f974d865ee94c9b87c22bfc040dd20d4483ca`, still based on upstream `4b667a1d`. It expands the diff from 37 to 255 added lines.

The research archive supplied with this checkpoint was byte-identical to the previous archive (`e44bf71163aaa017427c9bbc383875fcd63ed05df0965e777bf87db42f6ba5ea`), and filesystem search found only the QEMU40EN workcard patch, whose changes are already incorporated in the complete source diff. Consequently QEMU40DK, QEMU40EA, and QEMU40EN are recorded as source-preservation checkpoints, not successful test results.
