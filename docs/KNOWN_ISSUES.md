# Known issues

Updated: 2026-09-06

| ID | Area | Status | Impact / evidence | Next step |
|---|---|---|---|---|
| `GUI-01` | ML GUI lifecycle | `PARTIAL` | GUI works, but transitions and Canon repaint are not fully stable | Stabilize entry/exit without regressions |
| `INP-01` | DELETE mapping | `INVESTIGATING` | DELETE enters ML and navigates back; root exit behavior needs a reliable host event | Continue event/lifecycle audit |
| `INP-02` | Canon GUI flashes | `INVESTIGATING` | Shooting GUI/Q state and Canon menu may flash before ML | Evaluate masking only after stability |
| `LV-01` | ML GUI in LiveView | `OPEN` | Experimental paths have produced freeze/Err 70 | Do not promote current experiment |
| `OVL-01` | Zebra refresh/lag | `INVESTIGATING` | Real Zebra renders, but refresh/timing remains wrong | Preserve TEST124 geometry while isolating refresh |
| `OVL-02` | Global Draw | `PARTIAL` | Overlay infrastructure is not fully stable | Stabilize before dependent features |
| `RTC-01` | Date/time at boot | `OPEN` | Canon RTC/date-time may be corrupted when ML boots | Identify write path and add guarded test |
| `OVL-03` | Histogram | `UNVERIFIED` | No accepted hardware validation | Test after Global Draw stabilization |
| `OVL-04` | Focus Peaking | `UNVERIFIED` | No accepted hardware validation | Test after Global Draw stabilization |
| `OVL-05` | Waveform | `UNVERIFIED` | No accepted hardware validation | Test after Global Draw stabilization |

A test number or successful boot alone does not close an issue. An issue moves to `WORKING` or `VERIFIED` only with a recorded, repeatable hardware result and regression check.
