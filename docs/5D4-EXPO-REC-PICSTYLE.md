# Canon EOS 5D Mark IV — EXPO REC-PicStyle

Status: **HARDWARE CHECKPOINT**  
Firmware: **Canon EOS 5D Mark IV 1.3.3**

## Result

REC-PicStyle is enabled and hardware-functional on the 5D Mark IV. The
existing upstream implementation applies a selected Picture Style when Movie
recording starts, preserves the previous style and restores it when recording
stops.

This checkpoint depends on the completed EXPO05 Picture Style integration:
`FEATURE_PICSTYLE`, `NUM_PICSTYLES=11`, the validated
`PROP_PICTURE_STYLE` write path and the editable Picture Style properties.

## Source scope

The 5D4 platform removes `PROP_MVR_REC_START` from
`prop_handler_deny[]`, allowing the existing recording-state handler to run,
and enables `FEATURE_REC_PICSTYLE`.

No write permission for `PROP_MVR_REC_START` is added. No functional change
is made to `src/picstyle.c`, `src/shoot.c` or `src/lens.c`.

The upstream lifecycle is used unchanged:

- first transition from recording state 0 to nonzero: save the current style
  and apply the configured recording style;
- transition from state 2 to 0: restore the saved style.

## Hardware validation

With only the `PROP_MVR_REC_START` read handler enabled, normal boot, ML menu,
Movie LiveView and three recording cycles passed. Each recording remained
stable for more than five seconds, stopped normally and saved its clip. No
freeze or Err 70 occurred.

With REC-PicStyle enabled and `Force style for REC = OFF`, Standard remained
active before, during and after recording, demonstrating a neutral disabled
state.

Two independent active overrides passed:

- Standard before REC, Fine Detail during REC, Standard restored after STOP;
- Monochrome before REC, Portrait during REC, Monochrome restored after STOP.

Both recordings started and stopped normally, remained stable for more than
five seconds and saved their clips. The visible change in LiveView processing
provided an unambiguous runtime witness of application and restoration. No
freeze or Err 70 was observed.

## Known limitations

The ML menu is not currently accessible during active recording, so direct ML
menu readback of the temporary style is unavailable. This is a separate
Movie/GUI lifecycle limitation and does not prevent REC-PicStyle operation.

The known need to leave and re-enter Movie mode when ML is inaccessible after
powering on directly in Movie mode also remains separate and out of scope.

## Provenance

Local development baseline: `5d4-133-candidate` commit
`77bfce0ff4b08b93e0ae6719a883f14ad2ab8a33`. This is provenance only; the
integration base is the current `research/expo` patch series.

Build evidence:

- EXPO06A handler-read candidate: `238208 bytes`,
  SHA-256 `1de180896c33a7be9374d07050bd05fb3eb97285b4465816e83d09e8a45bf28f`;
- EXPO06B final REC-PicStyle candidate: `238912 bytes`,
  SHA-256 `a2556d784c1bcfb7785573531098e7988e119eaafffaee7e9c37a720ddc467ff`.

The generated binaries are evidence only and are not committed.

Patch `0007-5D4.133-EXPO-REC-PicStyle-HC1.patch` contains only the two
EXPO06-specific hunks. It preserves WB, ISO, Shutter, Aperture and Picture
Style, and excludes dirty-tree changes, diagnostics, generated binaries and
Canon proprietary material.

No merge to `main`, tag or release is implied.
