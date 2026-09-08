# Known issues

Updated: 2026-09-06

| ID | Area | Status | Impact / evidence | Next step |
|---|---|---|---|---|
| `GUI-01` | ML GUI lifecycle | `PARTIAL` | GUI works, but transitions and Canon repaint are not fully stable | Stabilize entry/exit without regressions |
| `INP-01` | DELETE mapping | `WORKING / HW TESTED` | M1-RC1 validates single-DELETE Electronic Level entry, submenu back, and root return to the level | Audit other INFO states, Auto-off/Wake, and LiveView separately |
| `INP-02` | Canon GUI flashes | `WORKING / HW TESTED` | M1-RC1 freezes the level frame and hides Canon Q/backing-GUI transitions without a black frame | Preserve ordering; extend only with separate hardware validation |
| `LV-01` | ML GUI in LiveView | `WORKING / HW TESTED` | TESTLV15D-B validates clean entry/exit over moving LiveView with hidden Q-host wheel isolation and no observed freeze/Err 70 | Preserve checkpoint; clean TESTLV instrumentation and test remaining display/wake states separately |
| `OVL-01` | Zebra refresh/lag | `INVESTIGATING` | Real Zebra renders, but refresh/timing remains wrong | Preserve TEST124 geometry while isolating refresh |
| `OVL-02` | Global Draw | `PARTIAL` | Overlay infrastructure is not fully stable | Stabilize before dependent features |
| `RTC-01` | Date/time at boot | `OPEN` | Canon RTC/date-time may be corrupted when ML boots | Identify write path and add guarded test |
| `OVL-03` | Histogram | `UNVERIFIED` | No accepted hardware validation | Test after Global Draw stabilization |
| `OVL-04` | Focus Peaking | `UNVERIFIED` | No accepted hardware validation | Test after Global Draw stabilization |
| `OVL-05` | Waveform | `UNVERIFIED` | No accepted hardware validation | Test after Global Draw stabilization |

A test number or successful boot alone does not close an issue. An issue moves to `WORKING` or `VERIFIED` only with a recorded, repeatable hardware result and regression check.


## GUI safety constraints from TEST263

- TEST263H: changing the Canon GUI host after `menu_shown == 1` produced freeze/Err 70. Do not restore this ordering.
- TEST263L: setting up or re-presenting the dedicated XIMR layer during the active Q transition produced intermittent freeze/Err 70.
- TEST263M and TEST263N-A showed that a transparent or opaque layer1 can remain active across physical Q and Canon MENU transitions when the backend is prearmed while Canon is stable.
- TEST263N-B was stable but removed the curtain too early, exposing a short Canon Menu flash.
- TEST263N-C kept the curtain through `menu_redraw_flood()`, final `menu_redraw_full()`, and `refresh_yuv_from_rgb()`, then blanked/disabled layer1. The tested entry path showed `black -> ML` with no reported freeze or Err 70.

These findings apply only to the tested Electronic Level entry path and do not close `GUI-01`, `INP-01`, or `LV-01`.


## M1-RC1 qualification

M1-RC1 supersedes TEST263N-C for active-display Electronic Level entry: single DELETE, frozen-level curtain, clean ML handoff, submenu/root return, and repeat-entry regression passed on hardware. TEST263H/L safety constraints remain binding. This does not close general GUI lifecycle, Auto-off/Wake, display-off/no-host, or LiveView issues.


## TESTLV15D-B qualification

LiveView entry and exit are hardware-verified with a frozen Canon GUI snapshot on dedicated XIMR layer1 and Canon layer0 hidden. Quick Control mode `0x29` remains logically active underneath ML so MAIN and REAR navigate ML without changing Tv/Av; periodic same-state `SetGUIRequestMode(0x29)` refresh prevents Canon's native timeout from returning the wheels to shooting control.

If mode `0x29` is lost unexpectedly while ML is open, the implementation must close/recover rather than leave shooting controls active under a visible ML menu. TESTLV diagnostics remain in this checkpoint, so it is not yet a cleaned main-branch candidate.
