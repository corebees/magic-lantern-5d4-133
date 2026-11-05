# 5D4 SHOOT source lineage (experimental)

Target: Canon EOS 5D Mark IV, firmware 1.3.3. This repository is a partial project repository; it does not contain the full upstream source tree.

## Reproduction order

1. Reconstruct the project's earlier source baseline `77bfce0ff4b08b93e0ae6719a883f14ad2ab8a33` from the upstream baseline and the seven-commit series linked from [the main README](../README.md). This SHA is a **local development commit**, not a commit in this partial GitHub repository; its tree was not independently retrieved for this integration.
2. Apply [01-R122N-BASE.patch](../patches/research/intervalometer/01-R122N-BASE.patch), an **experimental, broad** 19-file delta to R122-N. It includes SHOOT/BULB as well as GUI, Zebra, compositor, diagnostic TESTLV6/G10 and other coexisting local development. It is **not** a clean intervalometer-only change and is not independently hardware-validated as one whole.
3. Apply 02-SHOOT04-R122AC.patch on `research/intervalometer`.
4. Continue on `research/waveform-cache` with 03-SHOOT05-R21.patch and 04-SHOOT05-R24C.patch, in that order.

The transfer archive's SHA256SUMS verified all four exact patches. Its author reports isolated source replay and SHA-256 comparison of 21 target source files per stage against an AUDIT05 manifest; that manifest, source snapshots and build environment were **not included** here, so this repository integration did not independently reproduce the replay, rebuild or test on hardware. Git patch index IDs show the sequential base/result relationships. The patch objects in Git preserve the exact transfer bytes.

Original patch 01 SHA-256: `f32c7e079976dbf538762bba0ca26617c715b453a1ad262be28ef5919f626d76` (605100 bytes).

Do not apply these patches to the documentation-only GitHub `main` tree. They are research artifacts, not a release or a representation of a complete self-contained source checkout. No Canon firmware material or generated camera binary is supplied.
