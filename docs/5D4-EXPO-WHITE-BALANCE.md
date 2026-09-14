# Canon EOS 5D Mark IV — EXPO White Balance

Status: **HARDWARE CHECKPOINT**  
Firmware: **Canon EOS 5D Mark IV 1.3.3**

## Result

The EXPO White Balance controls are enabled and functional on the 5D Mark IV:

- Kelvin White Balance: hardware PASS
- Green/Magenta shift: hardware PASS
- Blue/Amber shift: hardware PASS
- R, G and B Custom WB multipliers: hardware PASS
- Auto adjust Kelvin + G/M: starts and executes on hardware

No freeze or Err 70 was observed in the successful final paths.

The validated write allowlist contains `PROP_WB_MODE_LV`,
`PROP_WB_KELVIN_LV`, `PROP_WB_MODE_PH`, `PROP_WB_KELVIN_PH`,
`PROP_WBS_GM`, `PROP_WBS_BA` and `PROP_CUSTOM_WB`.

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

The ML routine samples a central YUV region, adjusts Kelvin from B-R, and adjusts
G/M from `(R+B)/2-G`. It is a push-button neutral-target aid, not a replacement
for Canon's full-scene AWB. General-scene testing produced noticeably worse
results than Canon AWB. Quality improvements are deferred to separate research.

## Provenance

Local source baseline: `5d4-133-candidate` commit
`77bfce0ff4b08b93e0ae6719a883f14ad2ab8a33` (not present in this partial public
repository).

Exact hardware-tested source SHA-256 values:

- `platform/5D4.133/features.h`: `d81073bd62166a4d3b0ef99eac119d31e2f5a178b217114d6c8d46364c238332`
- `platform/5D4.133/property_whitelist.h`: `cef4887618371a80d5302315a1af48b0dc257e6f011d6eb34203bcf2d8b1c276`
- `src/shoot.c`: `18d6c8bfe1bdae1ff06d7557581e306c717d93fbfb93828d47c2c81dbc3612b7`

The attached research patch is a minimal integration delta against upstream
`reticulatedpines/magiclantern_simplified` commit
`d7e3407b8f69ddde30516e298d4e077daa16df0c`. It deliberately excludes unrelated
5D4 GUI, Zebra and debug configuration found in the local source snapshot.

The exact tested `shoot.c` duplicated the combined Auto WB declaration in its
non-5D4 preprocessor branch. The integration patch reuses the existing upstream
menu declaration instead. For `CONFIG_5D4`, the compiled functional path and
menu order are unchanged; the normalization avoids a duplicate entry on other
models. It is therefore a cleaned integration derivative, not a byte-identical
copy of the hardware-tested source.

Generated `autoexec.bin`, ROMs, Canon firmware material, logs and workcard
archives are not included. No merge to `main`, tag or release is implied.
