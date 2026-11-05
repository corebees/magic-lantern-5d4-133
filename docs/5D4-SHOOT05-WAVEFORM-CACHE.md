# SHOOT05 — deferred Waveform cache and bounded profiler

Target: Canon EOS 5D Mark IV, firmware 1.3.3. Branch `research/waveform-cache` descends from the SHOOT04 R122-AC commit on `research/intervalometer`.

## R21 source research

Apply [03-SHOOT05-R21.patch](../patches/research/waveform-cache/03-SHOOT05-R21.patch) after SHOOT04. SHA-256 `7e19e711daf3a921f7cda0e82efab102d5b9d0d920034df54e0472b737d12a7d` (10393 bytes). It changes `src/mem.c`, `src/mem.h`, `src/shoot.c`, `src/zebra.c`.

The delta adds an experimental persistent AllocateMemory-only helper with reserve/headroom checks and no backend fallback, defers two-tile Histogram and Waveform cache allocations to producer/low-priority paths, guards cache publication and readers, and adds a 5D4 Advanced Bracket **preview-only** menu entry. It does **not** trigger HDR exposures. The allocator comment itself cautions that its backend safety was not proven on hardware at the time of R21. Do not treat this entire patch as an R22 hardware-tested source snapshot.

## Separate R22 hardware checkpoint

The transfer handoff reports an earlier **10/10 hardware PASS for SHOOT05 R22**, but supplies **no R22 patch, source hash, test sequence or build artifact** and does not establish byte identity or the exact delta relative to R21. Preserve that report as a distinct historical hardware checkpoint, not as validation of this R21 artifact or of any subsequent profiler. Obtain the R22 workcard/source if a reproducible R22 commit is needed.

The transfer package reports isolated source replay against an AUDIT05 manifest, but the manifest and snapshots were not included. No build or hardware run was performed by repository integration. Mixed GUI/Zebra/TEST diagnostics from patch 01 remain experimental. No camera binary, Canon material, tag or release is included.
