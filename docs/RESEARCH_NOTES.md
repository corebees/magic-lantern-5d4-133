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


## Electronic Level / XIMR curtain sequence (TEST263L–N-C)

**CONFIRMED ON HARDWARE — PARTIAL CHECKPOINT**

Target: physical Canon EOS 5D Mark IV, firmware 1.3.3.

- TEST263L — failed/unsafe: creating or re-presenting the layer during the Q/Canon GUI transaction opened ML in roughly two of three attempts, then froze or raised Err 70.
- TEST263M — passed: a dedicated transparent layer1 remained active for 60 seconds and across physical Q/Q plus Canon MENU open/exit, with no Err 70.
- TEST263N-A — passed: the same prearmed layer changed from transparent to opaque black and remained black through Q/Q and MENU; disabling it restored the Electronic Level display.
- TEST263N-B — passed with cosmetic limitation: automated transparent prearm, opaque curtain, hidden Q, PLAY, and ML entry was stable, but the curtain handoff exposed a microflash of Canon Menu.
- TEST263N-C — passed: moving the handoff until after the redraw flood and final explicit ML publication removed the observed Canon Menu microflash. Final visible sequence: `Electronic Level -> black -> ML`.

The confirmed ordering is: prearm the backend while Canon is stable; later change/present only the layer contents; let Canon Q/PLAY run underneath; retain the opaque curtain until ML redraw flooding and final publication have completed; then blank and disable layer1.

The exact hardware-tested TEST263N-C source has been acquired. Final `src/menu.c` SHA-256: `e15b62ca710d9b7e6415fd3eed6b99992253815c0900d5b90f84436ee8b52c6e`. The research patch is anchored to TEST263K/J `src/menu.c` SHA-256 `2cef89a15d77302b321de3888a158fd2891c36286da86f03681e0d7ae30cb8dd`; applying it adds 372 lines and must reproduce the final hash. Earlier provenance remains recorded: TEST263N-A `cd9d9e1e1eed7c5c5b14f18659b1f38c34882e3c1af65a4388c6b312c0fd2d92`, TEST263N-B `3e2587aee2f1d72067c6f62c49ce4c226766bcb416ae582c5db83dfb8d9d468c`.


## M1-RC1 — stable Electronic Level entry

**HARDWARE VERIFIED MILESTONE** on physical Canon EOS 5D Mark IV firmware 1.3.3.

Validated UX: `Electronic Level -> single DELETE -> frozen Electronic Level frame -> ML`.

Transparent XIMR layer1 is prearmed automatically while the level is stable. DELETE snapshots the level frame. Synthetic Q and the Canon backing-mode transition run underneath while ML remains closed. ML opens only after the backing mode commits; the curtain remains until redraw flood, final `menu_redraw_full()`, and `refresh_yuv_from_rgb()` publish ML.

Regression PASS covered repeated entry, submenu DELETE to root, root DELETE to Electronic Level, leaving the level without opening ML, and physical Q/Q followed by level entry. No visible Canon Q/Menu frame, black transition, freeze, or Err 70 was observed.

Final source SHA-256: `f0d4c8642d611fc3d4e12d58e7e17d0ed8327605c3c178944c345650192d8011`. Hardware-tested `autoexec.bin`: `f68867942b980cfbbcdcd22caef499f83df8a6bde31670bcf853e13485d6332d` (not committed). Immediate predecessor N-C source: `e15b62ca710d9b7e6415fd3eed6b99992253815c0900d5b90f84436ee8b52c6e`.

Do not initialize XIMR after synthetic Q, change Canon host after ML becomes visible, or remove the curtain before final ML publication. `GUIMODE_PLAY` value 2 may visibly resemble Canon MENU on this hardware; describe it as the backing-GUI transition. Scope excludes Auto-off/Wake and LiveView.
