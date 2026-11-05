# SHOOT04 — native BULB timer and Intervalometer checkpoint

**Classification:** HARDWARE CHECKPOINT (reported physical Canon EOS 5D Mark IV, firmware 1.3.3).

The R122-AC candidate enables writes to the native Canon BULB timer property `0x80040060` by adding that property to the 5D4 write allow-list. The property handler and intervalometer-related source already exist in the broad R122-N baseline patch. Apply [01](../patches/research/intervalometer/01-R122N-BASE.patch), then [02](../patches/research/intervalometer/02-SHOOT04-R122AC.patch) to the local 77bfce0 source baseline; the Git patch IDs for `property_whitelist.h` chain from `a648885` to `eb412e8`.

The transfer handoff reports BULB and Intervalometer **PASS on the same hardware-tested SHOOT04 build**. The reported `make -j1` build passed; `autoexec.bin` was 276416 bytes with SHA-256 `0d175c22cddba16aa4427fe2e13bb67a29296f9debe2b8b66ef499835b26ced3`. The binary is evidence only and is not in this repository. No freeze or Err70 was reported for this checkpoint, but a full camera regression matrix was not supplied.

Patch 02 SHA-256: `b0279abd1e296a4f1ef30d58e60250ec0c1c5e83748a5b8981cc5e13539ac56e` (561 bytes).

**Boundaries:** the preceding 605100-byte baseline contains TESTLV6/G10 and GUI/Zebra/compositor experiments. These are not certified by the SHOOT04 result. The original workcard and AUDIT05 replay manifest were not attached to this repository integration; the hardware and build details above are attributed to the transfer handoff, not independently rerun here. The local source tree was not modified. No tag, release or `main` promotion.
