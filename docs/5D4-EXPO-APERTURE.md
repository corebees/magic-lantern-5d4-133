# Canon EOS 5D Mark IV — EXPO Aperture

Status: **HARDWARE CHECKPOINT**  
Firmware: **Canon EOS 5D Mark IV 1.3.3**

## Result

EXPO Aperture is enabled and hardware-functional on the 5D Mark IV for:

- menu access and property readback
- controlled `PROP_APERTURE` writes
- physical lens-limit handling
- Photo LiveView
- Movie LiveView and Movie REC transition
- still-photo capture

No EXPO04 freeze remains in the validated final build and no Err 70 was
observed.

## Enablement and property scope

`FEATURE_EXPO_APERTURE` is explicitly enabled for the platform. Only
`PROP_APERTURE` is added to the property-write allowlist.
`PROP_APERTURE_AUTO` and `PROP_APERTURE3` remain excluded because they were
not validated.

## Menu renderer fix

The Aperture update callback already computes its percentage icon from the
physical lens limits. The range-less menu entry therefore uses `IT_AUTO` under
`CONFIG_5D4`, avoiding the same `IT_PERCENT` renderer failure class found in
WB and Shutter. Other cameras retain the upstream icon type.

## Physical lens-limit clamp

The upstream editable menu path allowed aperture to wrap from one end of the
global aperture table to the other. On the tested EF 50mm f/1.8 II, decrementing
at f/1.8 wrapped to approximately f/22.6, while the reverse direction wrapped
back to f/1.8.

The 5D4 path now clamps directly to `lens_info.raw_aperture_min` and
`lens_info.raw_aperture_max`. The upstream wrapping logic remains unchanged
for other cameras. Declarations used only by that upstream path are excluded
from the 5D4 build to avoid `-Werror=unused-variable`.

After a forced rebuild of the actual `shoot.o`, hardware test EXPO04C-R5
confirmed:

- decrement at f/1.8 remains at f/1.8
- increment at the closed end remains at the lens limit
- no wrap to the opposite end
- no freeze
- no Err 70

Earlier R1/R2 attempts are classified NO UPDATE because stale `shoot.o` and
`autoexec.bin` files were tested.

## Hardware validation

Read-only testing matched Canon at f/2.8, f/4, f/5.6 and f/8. The first
controlled `PROP_APERTURE` write kept ML and Canon coherent without freeze or
Err 70.

Photo LiveView preview and exposure followed aperture changes and returned
correctly. Movie LiveView also remained coherent; START/STOP directly from ML
started recording, closed ML correctly, recorded stably, stopped normally and
saved the clip. Still-photo capture with an ML-set aperture passed and saved the
file.

ML may display raw Av more precisely than Canon's nominal label, for example
approximately f/22.6 while Canon displays f/22. This is not treated as a defect.

## Separate Movie GUI lifecycle observations

These observations are not attributed to EXPO04 and remain separate GUI/Movie
work:

- when the camera boots already in Movie mode, ML is initially inaccessible
  until the user leaves and re-enters Movie mode;
- the ML menu is not accessible during active Movie recording.

They do not block this Aperture hardware checkpoint.

## Provenance

Local development baseline: `5d4-133-candidate` commit
`77bfce0ff4b08b93e0ae6719a883f14ad2ab8a33`. This is provenance only; the
integration base is the current `research/expo` patch series.

Patch `0005-5D4.133-EXPO-Aperture-HC1.patch` contains only the EXPO04
Aperture delta. Temporary EXPO04 comments are omitted. No generated
`autoexec.bin`, Zebra, GUI-event, compositor or unrelated local changes are
included.

No merge to `main`, tag or release is implied.
