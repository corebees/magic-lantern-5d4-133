# Canon EOS 5D Mark IV — EXPO ISO

Status: **HARDWARE CHECKPOINT**  
Firmware: **Canon EOS 5D Mark IV 1.3.3**

## Result

The EXPO ISO feature is enabled and broadly hardware-validated on the 5D Mark
IV in normal photo mode, Photo LiveView and Movie LiveView:

- Main ISO: hardware PASS
- Canon analog ISO: hardware PASS
- Canon digital ISO: hardware PASS with 5D4-specific stepping
- Movie REC after main, analog and digital ISO changes: hardware PASS

ISO changes updated Canon's GUI and the LiveView preview. No persistent Tv or Av
changes and no Err 70 were observed.

## Property access

`PROP_ISO` is removed from `prop_handler_deny[]` and added to
`prop_write_allow[]`. Read tests correctly tracked Canon ISO 100, 400, 1600 and
Auto, including coherent equivalent, analog and digital components. Writes from
ML synchronized with Canon's GUI.

Representative main ISO transitions:

- 100 -> 160 -> 200 -> 320 -> 400
- 100 -> Auto
- Movie ISO 200 -> 320 -> 200

## Analog and digital components

Analog stepping preserved the digital component. For example, ISO 160
(Analog 200, Digital -0.3 EV) stepped to ISO 320 (Analog 400,
Digital -0.3 EV) and returned to ISO 160.

The upstream digital toggle walks 1/8-EV intermediate codes that the 5D4
`PROP_ISO` path rejects. Under `CONFIG_5D4`, the toggle therefore uses Canon's
accepted third-stop offsets `-3`, `0` and `+3`:

- ISO 160 = Analog 200 + Digital -0.3 EV
- ISO 200 = Analog 200 + Digital 0 EV
- ISO 250 = Analog 200 + Digital +0.3 EV

Other cameras retain the upstream stepping.

## Build dependency

The upstream Movie-mode ISO path referenced `bv_auto` unconditionally even
though that symbol exists only with `FEATURE_EXPO_OVERRIDE`. The patch selects
`MAX_ISO_BV` only when that feature is enabled and otherwise uses `MAX_ISO`.
This allows `FEATURE_EXPO_ISO` to link independently.

## LiveView and Movie validation

Main, analog and digital ISO controls passed in Photo LiveView and Movie
LiveView. The preview updated correctly, ML exit restored the Canon view, and
Tv and Av remained unchanged. Direct START/STOP while the ML menu was open also
passed and closed the ML menu correctly.

## Isolated Movie REC freeze

EXPO02J-R2 recorded one freeze after ML changed Movie ISO 200 -> 320. Canon's
GUI and preview were correct, REC did not start, and no Err 70 occurred.

The event was not reproduced in controlled follow-up:

- Canon-only ISO 200 and 320 followed by REC: PASS
- ML ISO write followed by Canon 320 -> 400 -> 320 and REC: PASS
- ML ISO write with approximately 10 s or 1 s settling: PASS
- Diagnostic binary immediate REC: 10/10 PASS
- Clean final binary immediate REC: 10/10 PASS
- Analog ISO followed by direct REC: PASS
- Digital ISO followed by direct REC: PASS

This remains a real but currently non-reproducible hardware observation. The
feature is not described as definitively fixed, and no arbitrary delay is added.

Temporary counters showed identical `PROP_ISO` callback behavior for equivalent
Canon and ML transitions and no `PROP_ISO_AUTO` callbacks. All EXPO02 temporary
diagnostics were removed before the final audit.

## Provenance

Local development baseline: `5d4-133-candidate` commit
`77bfce0ff4b08b93e0ae6719a883f14ad2ab8a33`.

Final hardware-tested local source SHA-256 values:

- `platform/5D4.133/features.h`: `2f2a241d6d87929f364ad278042775f0025153b367e26679d7099fbcd6882638`
- `platform/5D4.133/property_whitelist.h`: `11721006e6410a42d846deb45f9187e8fb0f4a963e329183f6c7a3d8fcf0e288`
- `src/shoot.c`: `e28b581b8b4ebf16100d84b7e419aee8a2a50fd3053d81c674943cd4fecb6c0e`
- `src/lens.c`: `0037c5222e4a1fac00de3d992cbcd7fb75511ba8bebd9344b852111c6154c3d1`

These are complete local-tree hashes containing pre-existing work and are
provenance evidence only. Patch `0003-5D4.133-EXPO-ISO-HC1.patch` reconstructs
only the ISO delta on top of the existing EXPO WB patch series. The stale local
comments claiming UI-only status and blocked writes are intentionally omitted.
No ISO-specific `src/lens.c` change is required.

The final camera build was 232256 bytes with SHA-256
`31a8c40b356868a0d32386df3c52f96b2277f04fad3bdce6753cc4cec5d34523`.
It is build evidence only and is not included.

Generated binaries, ROMs, Canon firmware material, logs, temporary diagnostics,
unrelated GUI/Zebra work and local worktree residue are not included. No merge
to `main`, tag or release is implied.
