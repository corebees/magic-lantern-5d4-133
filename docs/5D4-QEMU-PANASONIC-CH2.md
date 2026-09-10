# 5D4 Panasonic CH2 multi-byte receive frontier

Updated: 2026-09-10

Status: `RESEARCH / QEMU AND BOUNDED STATIC RE / NOT HARDWARE VALIDATION`

## Scope

This note records the current Canon EOS 5D Mark IV firmware 1.3.3 QEMU blocker. It contains distilled observations only: no Canon firmware, ROM dump, bulk disassembly, generated binary, or physical-camera validation.

## Reached startup path

Current QEMU research reaches:

`dispDevCtrl_ConnectHDMI -> GUI_Initialize -> GuiMainTask -> GuiInitializeGraphics -> Pana_Init`

`Pana_Init` does not complete its first RESET_COMPLETE phase. The Panasonic snapshot field at offset 84 remains set to 1. A bounded static audit identified the clearing writer at `FE1C20D6`, which stores zero to that field only after the preceding command-processing path succeeds.

## Panasonic commands

The relevant command list includes `0x1F`, `0x1D`, `0x2D`, `0x3C`, `0x3D`, and `0x80`.

| Command | Operation | Slave/register | RX length | Destination |
|---|---|---|---:|---|
| `0x3C` | READ | `0x70:0x02` | 2 bytes | Panasonic snapshot near +92 |
| `0x3D` | READ | `0x70:0x04` | 1 byte | Panasonic snapshot near +94 |

## CH2 receive-count contract

Bounded static reverse engineering of the Canon CH2 path established:

- the transaction descriptor carries TX length at +14 and RX length at +16;
- `FE14E0B4` performs the address/register phase and calls the receive path at `FE14DCEA`;
- Canon reads `D6050010` and interprets bits 31:24 as the actual received-byte count;
- Canon requires the actual count to equal the requested count before consuming payload data.

For command `0x3C`, the requested count is 2.

## QEMU40NR incompatibility

QEMU40NR reports:

`D6050010 = 0x01000000`

Therefore the emulator reports an actual count of 1. Its current sequence supports exactly one byte:

`RX ready(count=1) -> RXDATA byte -> clear ready -> arm STOP pre-gate`

That behavior is compatible with earlier one-byte Audio/Panasonic reads but cannot complete command `0x3C`:

`requested 2 -> reported 1 -> comparison fails -> CH2 receive failure`

This is a causal transport incompatibility, not yet a completed Panasonic fix.

Known QEMU40NR identifiers:

- `hw/eos/eos.c` SHA-256: `c7e5ae2ec8ad441f582c06a398b60844ccacefdd2c416c6c51a57aa8eeb786ad`
- local QEMU binary SHA-256: `ca8d30e4dbf90adcf9111550ce94c85e918dc1adf05ff922f56f6684d1612a67` (binary not committed)

## Required model

A correct generic model should behave conceptually as:

`RX ready(count=N) -> report N -> consume RXDATA -> decrement remaining -> clear ready and arm STOP after byte N`

Do not globally change RX count from 1 to 2; that would risk regressing existing one-byte transactions. The preferred implementation derives requested RX length from controller state. A transfer-specific `0x70:0x02` diagnostic may be used only as a narrow experiment.

The already-validated STOP/TIRQ/SIRQ behavior should remain unchanged unless new evidence requires it.

## Evidence boundary

QEMU40OU confirmed read-only that QEMU40NR retains isolated hooks for transfer arm, RX count, RX payload, and STOP pre-gate. QEMU40OU-R2 is only a proposed diagnostic for recording writes preceding the read-arm command and recovering requested RX length dynamically. It has not been run or validated.

Panasonic payload values remain unmodelled and current reads return synthetic zero bytes. Even after fixing the receive count, payload semantics and RESET_COMPLETE progression require separate validation.

## Next step

Implement and runtime-test dynamic multi-byte CH2 RX accounting while preserving one-byte reads. Publish a qemu-eos source patch only after the new model is clean, isolated, and reproducibly QEMU-validated against upstream `reticulatedpines/qemu-eos` branch `qemu-eos-v4.2.1`, commit `4b667a1d3c08ab7a55835d15ddbd884fa754946d`.

No physical-camera claim, tag, release, or main-branch merge follows from this finding.
