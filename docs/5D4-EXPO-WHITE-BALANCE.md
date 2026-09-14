# Canon EOS 5D Mark IV — EXPO White Balance

Status: **HARDWARE CHECKPOINT**  
Firmware: **Canon EOS 5D Mark IV 1.3.3**

## Result

The EXPO White Balance controls are enabled and functional on the 5D Mark IV:

- Kelvin White Balance: hardware PASS
- Green/Magenta shift: hardware PASS
- Blue/Amber shift: hardware PASS
- R, G and B Custom WB multipliers: hardware PASS
- Canon Auto WB: hardware PASS
- Reset WB Shift: hardware PASS
- Auto adjust Kelvin + G/M: starts and executes on hardware

No freeze or Err 70 was observed in the successful final paths.

The validated write allowlist contains `PROP_WB_MODE_LV`,
`PROP_WB_KELVIN_LV`, `PROP_WB_MODE_PH`, `PROP_WB_KELVIN_PH`,
`PROP_WBS_GM`, `PROP_WBS_BA` and `PROP_CUSTOM_WB`.

## Canon Auto WB and shift reset

The 5D4-specific **Canon Auto WB** action writes `WB_AUTO` to both
`PROP_WB_MODE_LV` and `PROP_WB_MODE_PH`. Hardware testing confirmed that ML
reports Auto, Canon reports AWB, LiveView returns to Canon AWB, and existing WB
shift values remain unchanged.

The separate **Reset WB Shift** action writes zero through the existing G/M and
B/A setters. It preserves the selected WB mode; hardware testing confirmed both
axes return to zero and Canon's GUI remains coherent.

## Multiplier submenu freeze

The upstream R/G/B multiplier entries selected `IT_PERCENT` without defining a
valid range. With `min == max == 0`, `NUM_CHOICES(entry)` is one, so the generic
renderer evaluates a percentage with a zero denominator. Hardware isolation
showed that removing the R entry avoided the freeze, restoring it with
`IT_PERCENT` reproduced the freeze, and using `IT_AUTO` passed for all three
channels. The update callback already supplies the percentage icon dynamically.

## Custom White Balance

`PROP_CUSTOM_WB` writes were validated on hardware and Canon's GUI reports the
resulting Custom WB. The existing setter rounds R and B gains to 16-unit
boundaries. Once aligned to that boundary, the tested values were reversible:

- R: 1.560 -> change -> 1.560
- G: 1.000 -> 1.015 -> 1.000
- B: 2.064 -> 2.133 -> 2.064

## 5D4 LiveView state

The 5D4 port intentionally tracks Canon LiveView through `lv_5d4`; the legacy
global `lv` remains disabled. The combined Auto WB launcher and its Kelvin and
G/M worker guards therefore use `lv_5d4` under `CONFIG_5D4`, while all other
models retain the upstream `lv` path.

## Auto WB limitation

The ML **Auto adjust Kelvin + G/M** routine samples a central YUV region,
adjusts Kelvin from B-R, and adjusts G/M from `(R+B)/2-G`. It is a push-button
neutral-target aid, not a replacement for Canon's full-scene AWB. General-scene
testing produced noticeably worse results than Canon AWB. This limitation does
not affect the separate Canon Auto WB action. Quality improvements are deferred
to separate research.

## Power lifecycle A/B validation

Controlled PRE-EXPO and EXPO comparisons found the approximately four-second
power-on time and intermittent absence of Canon sensor cleaning during shutdown
on the PRE-EXPO candidate as well. A previously observed need for a wake button
press was not reproduced in later controlled runs. Upstream White Balance and
the final EXPO candidate showed similar intermittent shutdown behavior.

No startup, wake or shutdown regression is therefore currently attributed to
the EXPO White Balance changes. The intermittent Canon shutdown/sensor-cleaning
behavior remains a separate 5D4 platform lifecycle issue.

## Provenance

Local source baseline: `5d4-133-candidate` commit
`77bfce0ff4b08b93e0ae6719a883f14ad2ab8a33` (not present in this partial public
repository).

The exact final workcard patch has SHA-256
`1b2eafeaf0b2922d4157f8e42ddd6e726884661fbadab8204180da265e2aaca7`.
Temporary AWB/L4 NotifyBox probes were removed before that patch was captured;
`src/menu.c` was verified byte-identical to its pre-isolation snapshot.

The source series in this branch is split into:

1. `0001-5D4.133-EXPO-white-balance-HC1.patch`: enablement, property whitelist,
   `lv_5d4` guards, and the `IT_AUTO` multiplier fix.
2. `0002-5D4.133-EXPO-WB-Canon-AWB-reset-HC1.patch`: the two final 5D4-only
   hardware-validated actions for Canon AWB and WB-shift reset.

Together these reproduce the functional changes from the final workcard while
retaining the cleaned upstream menu layout established in `0001`.

The final camera build was 230592 bytes with SHA-256
`64b88e774cfdcf3dab92dad1e5b87dfdf5627b108b278c18dac63822b5ebf3a9`.
It is build evidence only and is not included.

Generated `autoexec.bin`, ROMs, Canon firmware material, logs, diagnostics and
workcard archives are not included. No merge to `main`, tag or release is
implied.
