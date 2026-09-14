# Canon EOS 5D Mark IV — EXPO Picture Style

Status: **HARDWARE CHECKPOINT**  
Firmware: **Canon EOS 5D Mark IV 1.3.3**

## Result

EXPO Picture Style is enabled and hardware-functional on the 5D Mark IV for
active-style selection and editing of all validated 5D4 Picture Style
parameters.

The platform count is set to 11 so Auto and Fine Detail are represented
correctly together with the three-part sharpness controls. All six parameters
were visible: strength, fineness, threshold, contrast, saturation and color
tone.

## Property scope

The checkpoint enables `FEATURE_PICSTYLE` and permits writes to
`PROP_PICTURE_STYLE` plus the settings properties for Standard, Portrait,
Landscape, Fine Detail, Neutral, Faithful, Monochrome and UserDef1–3.

`PROP_PICSTYLE_SETTINGS_AUTO` remains excluded. Auto is selectable, but its
parameter controls are intentionally non-editable, matching Canon behavior.
`FEATURE_REC_PICSTYLE` is not enabled or validated and remains separate
future work. No functional change to `src/picstyle.c` is required.

## Hardware validation

Canon-to-ML readback passed for Auto, Standard, Portrait, Landscape, Fine
Detail, Neutral, Faithful, Monochrome and UserDef1. Active-style writes passed
for the tested styles, including Fine Detail and Monochrome.

All six Standard parameters were changed individually while Canon and ML
remained coherent and unmodified parameters were preserved. Fine Detail,
UserDef1 and the remaining editable styles were then covered successfully:
Portrait, Landscape, Neutral, Faithful, Monochrome, UserDef2 and UserDef3.

Final smoke testing passed in normal photo use, Photo LiveView, Movie LiveView,
direct Movie REC after a style or parameter change, and still-photo capture.
Preview response, ML closure on REC start, stable recording, stop and saved
files all passed. No freeze or Err 70 was observed in EXPO05 hardware tests.

## Non-results and build note

The first forced build using whole-target `make -B` failed because the flag
propagated into recursive TCC make and triggered its intentional
`Please run ./configure` trap. This was a build-procedure error and requires
no TCC source or configuration change.

The initial EXPO05D candidate did not actually include the Standard settings
property in the whitelist. Its apparent write failure is classified
**NO UPDATE**, not a 5D4 property-write failure.

## Provenance

Local development baseline: `5d4-133-candidate` commit
`77bfce0ff4b08b93e0ae6719a883f14ad2ab8a33`. This is provenance only; the
integration base is the current `research/expo` patch series.

Final hardware-tested build evidence:

- artifact: `EXPO05I-final-autoexec.bin`
- size: `238272 bytes`
- SHA-256: `8cf098a6dd2dda6f6dd6245f7f1c98da89e85ac947d55c67975e2d68daf711fa`

The generated binary is evidence only and is not committed.

Patch `0006-5D4.133-EXPO-Picture-Style-HC1.patch` contains only the EXPO05
Picture Style delta. It preserves the already-integrated WB, ISO, Shutter and
Aperture series and excludes temporary diagnostics, local dirty-tree changes,
generated binaries and Canon proprietary material.

No merge to `main`, tag or release is implied.
