# SHOOT05 R24C — bounded combined-graph profiler

**Classification: RESEARCH UPDATE — not hardware tested.**

Apply [04-SHOOT05-R24C.patch](../patches/research/waveform-cache/04-SHOOT05-R24C.patch) after the R21 patch on the SHOOT04 source chain. Its `src/zebra.c` Git patch index starts at `7330834`, the exact result ID of patch 03, and ends at `3a1d6c7`. Original patch SHA-256: `e3521c4d470779040ca9657db831286dea477d51c653cf78cf136d8c744d0070` (7279 bytes).

The delta adds a bounded 192-sample, in-memory profiler for the low-priority combined Histogram/Waveform producer. It collects YUV, Waveform, Histogram, total and inter-start timings, with read-only entries in ML Debug. Source inspection finds no added disk I/O or heap allocation in the READY path. This is an implementation description, **not** a camera stability or performance result.

**Hardware status: pending.** No R24C physical-camera run, freeze/Err70 outcome, performance measurement, regression pass or global-startup claim is available. In particular, the separate reported R22 10/10 PASS does not validate this changed `zebra.c`. The package's reported isolated patch replay is not a build; its AUDIT05 manifest was not attached and replay was not independently reproduced here. Retest the full dependent candidate before any promotion. No `main` merge, tag or release.
