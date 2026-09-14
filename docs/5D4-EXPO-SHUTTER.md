# Canon EOS 5D Mark IV — EXPO Shutter

Status: **HARDWARE CHECKPOINT**  
Firmware: **Canon EOS 5D Mark IV 1.3.3**

## Result

EXPO Shutter is enabled and hardware-functional on the 5D Mark IV for:

- menu access and readback
- controlled `PROP_SHUTTER` writes
- fine/intermediate Tv values
- Photo LiveView
- Movie LiveView and Movie REC transition
- still-photo capture

No deterministic freeze or Err 70 remains in the tested paths.

## Enablement and property scope

`FEATURE_EXPO_SHUTTER` is enabled explicitly in
`platform/5D4.133/features.h`. Although `all_features.h` places it under
`CONFIG_PROP_REQUEST_CHANGE`, explicit platform enablement was required for the
5D4 build to compile the menu entry.

Only `PROP_SHUTTER` is added to the write allowlist. `PROP_SHUTTER_AUTO`
remains excluded because it was not validated.

## EXPO menu freeze

With upstream `IT_PERCENT`, entering EXPO reproducibly froze the camera because
the Shutter entry has no menu min/max range. This is the same renderer failure
class previously isolated in the Custom WB multipliers.

Under `CONFIG_5D4` the Shutter entry now uses `IT_AUTO`; its update callback
already supplies the percentage icon. Other cameras retain `IT_PERCENT`.

After this change the camera booted, ML and EXPO opened normally, the Shutter
entry was present, and no freeze or Err 70 occurred.

## Hardware validation

Readback matched Canon in normal photo mode and LiveView/Movie for 1/25, 1/50,
1/100 and 1/250.

The first controlled write started at 1/125:

- ML +1 -> ML and Canon 1/160
- ML -1 -> ML and Canon 1/125

No freeze or Err 70 occurred, validating the `PROP_SHUTTER` write path.

In Movie LiveView, changes from 1/50 to 1/60 and then 1/80 updated Canon's GUI
and preview. START/STOP directly from ML started recording, closed ML correctly,
recorded stably for at least five seconds, stopped normally and saved the clip.

Still-photo capture with ML-set normal and intermediate shutter values passed
and saved the files without freeze or Err 70.

## Fine Shutter behavior

ML may apply intermediate Tv values while Canon's GUI rounds its display to a
nominal label. For example, ML 1/180 may be displayed by Canon as 1/200.
LiveView preview, exposure meter and histogram followed the ML Tv, confirming
that the intermediate value is real. This is consistent with Magic Lantern's
upstream fine-tune design and is not itself a defect.

## Observations and limits

One early ML 1/45 display while Canon showed 1/25 was not reproduced. Later
controlled read tests were coherent; this observation is neither described as
fixed nor treated as a deterministic bug.

Testing covers the recorded ranges and workflows only. This remains a research
branch hardware checkpoint, not a main milestone.

## Provenance

Local development baseline: `5d4-133-candidate` commit
`77bfce0ff4b08b93e0ae6719a883f14ad2ab8a33`. This is provenance only, not the
integration base.

Patch `0004-5D4.133-EXPO-Shutter-HC1.patch` contains only the Shutter delta on
top of the current WB and ISO series. Temporary EXPO03 comments are normalized.
No generated `autoexec.bin`, Zebra, GUI-event, compositor or unrelated local
worktree changes are included.

No merge to `main`, tag or release is implied.
