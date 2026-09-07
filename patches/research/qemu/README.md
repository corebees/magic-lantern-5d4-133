# 5D4.133 QEMU research checkpoint

Classification: `RESEARCH UPDATE`

This directory preserves redistributable QEMU-side work for Canon EOS 5D Mark IV firmware 1.3.3. It intentionally excludes Canon ROM/FIR/SFDATA, disk images, work cards, build outputs, raw GDB/stdout/stderr transcripts, personal paths, and generated binaries.

## Baseline

- Upstream: `reticulatedpines/qemu-eos`
- Branch: `qemu-eos-v4.2.1`
- Commit: `4b667a1d3c08ab7a55835d15ddbd884fa754946d`
- Baseline `hw/eos/eos.c` blob: `c2039fdd18340bebe7406f388442654b18ba3f4c`

## Patches

Both files are complete alternatives based on the same clean upstream commit; do **not** apply them cumulatively.

- `0001-qemu-eos-5D4-checkpoint.patch`: QEMU38ZZQ checkpoint, SHA-256 `1d0b28418ffe4cd7a5cee8a89f6b41d3c17f776bab9f992c3b72b2be842d6dc7`.
- `0002-qemu-eos-5D4-QEMU40-current.patch`: current QEMU40 experimental checkpoint, SHA-256 `b93a6e4c76fb69cae69401dacc2f974d865ee94c9b87c22bfc040dd20d4483ca`.

Apply from a clean checkout at the baseline commit:

```sh
git apply --check 0002-qemu-eos-5D4-QEMU40-current.patch
git apply 0002-qemu-eos-5D4-QEMU40-current.patch
```

The patch contains two deliberately distinct changes:

1. `QEMU VERIFIED`: extend MEMDIV handling to the 5D4 range `0xD9000A20–0xD90015FF` and setup offset `0x0A24`.
2. `EXPERIMENTAL`: treat a 5D4 write of value 3 to `0xD20F0110` as an asynchronous MOCom/Omar completion and trigger IRQ `0x9C`. This is diagnostic scaffolding, not a complete MOCom model.

The scripts directory retains the reusable QEMU37Q–QEMU38B GDB/static-audit scripts. They require a user-supplied lawful ROM outside this repository.

## QEMU40 additions

The second complete patch retains the earlier MEMDIV and MOCom/Omar work and adds three unverified diagnostics:

- `QEMU40DK`: D200 channel-0 pending/ack model using `D2000208`, `D2000400`, and IRQ `0x8D`.
- `QEMU40EA`: route the recovered 5D4 JpCore bases `D0100000`, `D0110000`, and `D0120000` to the existing JpCore emulator.
- `QEMU40EN`: narrow ResManagPostS TX0/RX1 diagnostic for `D2000004`, TX IRQ `0x0D`, RX IRQ `0x1C`, and a two-word receive FIFO.

No QEMU39–QEMU41 report or new reusable script accompanied this source snapshot. These additions are therefore `EXPERIMENTAL / NOT YET QEMU-VERIFIED`; the earlier MEMDIV result keeps its verified status.
