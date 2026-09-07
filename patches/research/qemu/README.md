# 5D4.133 QEMU research checkpoint

Classification: `RESEARCH UPDATE`

This directory preserves redistributable QEMU-side work for Canon EOS 5D Mark IV firmware 1.3.3. It intentionally excludes Canon ROM/FIR/SFDATA, disk images, work cards, build outputs, raw GDB/stdout/stderr transcripts, personal paths, and generated binaries.

## Baseline

- Upstream: `reticulatedpines/qemu-eos`
- Branch: `qemu-eos-v4.2.1`
- Commit: `4b667a1d3c08ab7a55835d15ddbd884fa754946d`
- Baseline `hw/eos/eos.c` blob: `c2039fdd18340bebe7406f388442654b18ba3f4c`

## Patch

`0001-qemu-eos-5D4-checkpoint.patch` is the exact local diff. SHA-256: `1d0b28418ffe4cd7a5cee8a89f6b41d3c17f776bab9f992c3b72b2be842d6dc7`.

Apply from a clean checkout at the baseline commit:

```sh
git apply --check 0001-qemu-eos-5D4-checkpoint.patch
git apply 0001-qemu-eos-5D4-checkpoint.patch
```

The patch contains two deliberately distinct changes:

1. `QEMU VERIFIED`: extend MEMDIV handling to the 5D4 range `0xD9000A20–0xD90015FF` and setup offset `0x0A24`.
2. `EXPERIMENTAL`: treat a 5D4 write of value 3 to `0xD20F0110` as an asynchronous MOCom/Omar completion and trigger IRQ `0x9C`. This is diagnostic scaffolding, not a complete MOCom model.

The scripts directory retains the reusable QEMU37Q–QEMU38B GDB/static-audit scripts. They require a user-supplied lawful ROM outside this repository.
