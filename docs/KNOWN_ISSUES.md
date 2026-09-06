# Known issues

Updated: 2026-09-06

| ID | Area | Status | Impact / evidence | Next step |
|---|---|---|---|---|
| `GUI-01` | ML GUI lifecycle | `PARTIAL` | GUI works, but transitions and Canon repaint are not fully stable | Stabilize entry/exit without regressions |
| `INP-01` | DELETE mapping | `INVESTIGATING` | DELETE enters ML and navigates back; root exit behavior needs a reliable host event | Continue event/lifecycle audit |
| `INP-02` | Canon GUI flashes | `PARTIAL / HW TESTED` | TEST263N-C hides Q and Menu/PLAY flashes for Electronic Level entry by holding a prearmed XIMR curtain through final ML publication | Acquire exact N-C source; remove double DELETE/black curtain; run regression matrix |
| `LV-01` | ML GUI in LiveView | `OPEN` | Experimental paths have produced freeze/Err 70 | Do not promote current experiment |
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
