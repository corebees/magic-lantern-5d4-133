# Experimental Magic Lantern port for Canon EOS 5D Mark IV (1.3.3)

This private repository tracks experimental work on the Magic Lantern port for the Canon EOS 5D Mark IV running Canon firmware **1.3.3**.

The project is built on the existing Magic Lantern codebase and on earlier 5D Mark IV porting and reverse-engineering work by Magic Lantern developers and contributors. It is not a port created from scratch here.

> **Warning:** this is experimental camera firmware work. It is not a stable release, may crash or corrupt camera settings, and is used entirely at the tester's risk.

## Current status

| Area | Status | Evidence |
|---|---|---|
| Magic Lantern boot on 5D4 1.3.3 | `VERIFIED / HW TESTED` | Repeated camera boot |
| Magic Lantern GUI | `WORKING` | Opens on hardware; lifecycle is not fully stable |
| LiveView framebuffer path | `VERIFIED / HW TESTED` | Active/current image identified in DispVram control block |
| LiveView geometry | `VERIFIED / HW TESTED` | 1024×600 |
| Zebra geometry | `VERIFIED / HW TESTED` | TEST124 frozen baseline |
| Real Magic Lantern Zebra | `WORKING / HW TESTED` | Renders on camera |
| Zebra refresh/lag | `INVESTIGATING` | Timing/refresh behavior remains open |
| Global Draw | `PARTIAL` | Infrastructure is not fully stable |
| GUI/input DELETE mapping | `INVESTIGATING` | Entry/back/root-exit behavior differs |
| RTC/date-time corruption at ML boot | `OPEN` | Reproducible issue, unresolved |
| Histogram | `UNVERIFIED` | No accepted hardware validation yet |
| Focus Peaking | `UNVERIFIED` | No accepted hardware validation yet |
| Waveform | `UNVERIFIED` | No accepted hardware validation yet |

`WORKING` does not imply complete, regression-free, or release-ready. Nothing is labelled `FIXED` without a repeatable hardware test.

## Documentation

- [Port status](docs/5D4_PORT_STATUS.md)
- [Known issues](docs/KNOWN_ISSUES.md)
- [Testing policy and report template](docs/TESTING.md)
- [Research notes](docs/RESEARCH_NOTES.md)

## Repository boundaries

This repository separates:

1. upstream Magic Lantern work;
2. earlier 5D Mark IV porting work;
3. changes and findings verified by this project on real hardware;
4. experimental tests and hypotheses that remain unconfirmed.

Canon firmware, ROM/SFDATA dumps, proprietary binaries, private test backups, and redistribution-restricted material must not be committed. Generated camera binaries are intentionally excluded from source-control history; validated builds are recorded by source commit, toolchain, hashes, and hardware-test report.
