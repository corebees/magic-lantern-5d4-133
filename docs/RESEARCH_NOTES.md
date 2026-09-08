# Research notes

Updated: 2026-09-06

Labels used here: `CONFIRMED ON HARDWARE`, `STATIC RE`, `OBSERVED`, `HYPOTHESIS`, `UNVERIFIED`, `SUPERSEDED`.

## Framebuffer and LiveView

- `CONFIRMED ON HARDWARE`: LiveView geometry is 1024×600.
- `CONFIRMED ON HARDWARE`: the active/current image is obtained from the DispVram control block; the observed field is at `DispVram + 0x78`.
- The address is a field observation for this firmware path, not a portable ABI guarantee.

## Zebra

- `CONFIRMED ON HARDWARE`: TEST124 is the accepted Zebra geometry baseline and should not be modified while refresh work continues.
- `CONFIRMED ON HARDWARE`: real Magic Lantern Zebra rendering is visible on camera.
- `OBSERVED`: refresh/lag behavior remains incorrect.
- `HYPOTHESIS`: expected reference behavior is diagonal 45-degree stripes with a roughly two-second visible/two-second hidden cycle; timing still needs direct acceptance testing against the target implementation.

## GUI and input

- `CONFIRMED ON HARDWARE`: ML GUI opens and submenu navigation works.
- `OBSERVED`: DELETE behavior differs between root and submenu contexts; a Canon Q-related repaint/event can restore the Canon GUI.
- `OBSERVED`: recent fake-Q and masking tests reduce some transitions but still expose Canon GUI flashes.
- `OBSERVED`: experimental LiveView menu-entry paths have frozen or produced Err 70.
- `UNVERIFIED`: no-host and static-curtain approaches are not accepted fixes.

## Global Draw and dependent tools

- `OBSERVED`: Global Draw is partial and remains the prerequisite for stable overlay-dependent features.
- `UNVERIFIED`: Histogram, Focus Peaking, and Waveform have no accepted hardware validation.

## RTC

- `OBSERVED`: Canon date/time corruption may occur at ML boot.
- `OPEN`: cause and fix are not yet validated.


## Doom module feasibility

- `RESEARCH`: [Doom port feasibility for the 5D4.133](DOOM_PORT_FEASIBILITY.md) is documented from the existing Doom550D Magic Lantern module.
- `UNVERIFIED`: Doom module loading, rendering, input, audio, filesystem writes, and cleanup have not been tested on physical 5D4 hardware.
- Keep physical LCD (~900×600 inferred), LiveView YUV (`1024×600` observed), and ML overlay coordinates (`720×480`) strictly separate.
