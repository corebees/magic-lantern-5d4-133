# Hardware testing policy

Target hardware: Canon EOS 5D Mark IV, Canon firmware 1.3.3.

## Evidence levels

Static reverse engineering, emulator observations, hypotheses, and physical-camera observations must be labelled separately. Only a physical-camera result may receive `HW TESTED`. A result should not be called fixed until the intended behavior is repeatable and relevant regressions have been checked.

## Minimum test record

For every candidate build, record:

- source commit or exact patch provenance;
- toolchain version and relevant build options;
- generated artifact size and full SHA-256;
- camera model and Canon firmware;
- camera state: photo/LiveView/movie, display state, menu state, and card slot;
- exact action sequence;
- expected and observed results;
- number of repetitions;
- freeze, Err code, RTC change, or other regression;
- final status: PASS, FAIL, PARTIAL, or NOT TESTED.

## Status promotion

| From | To | Requirement |
|---|---|---|
| `UNVERIFIED` | `HW TESTED` | Direct observation on the target camera |
| `INVESTIGATING` | `WORKING` | Repeatable intended behavior plus regression check |
| `WORKING` | `VERIFIED` | Reviewed evidence and stable reproduction |
| Any | `FIXED` wording | Hardware-confirmed resolution of the original defect |

## Test report template

```markdown
# TESTxxx — short title
Date:
Source commit / patch:
Toolchain:
Artifact SHA-256:
Camera / firmware: Canon EOS 5D Mark IV / 1.3.3
Initial state:
Steps:
Expected:
Observed:
Repetitions:
Regressions:
Result: PASS | FAIL | PARTIAL | NOT TESTED
Classification: HW TESTED | OBSERVED | HYPOTHESIS | UNVERIFIED
```

Never attach Canon ROMs, SFDATA, FIR files, proprietary dumps, or unreviewed private backup archives.
