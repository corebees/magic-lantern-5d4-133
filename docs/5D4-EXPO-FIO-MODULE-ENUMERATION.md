# Canon EOS 5D Mark IV — FIO module enumeration

Status: **HARDWARE CHECKPOINT**  
Firmware: **Canon EOS 5D Mark IV 1.3.3**

## Result

The missing top-level Modules tab was traced to the 5D4 directory-entry layout
returned by `FIO_FindFirstEx`, not to ETTR visibility or module configuration.

Before the fix, Canon enumerated 25 entries in `ML/MODULES/`, but
`module_valid_filename()` accepted none and `module_cnt` remained zero.
Hardware offset probing showed that the filename begins at offset `0x18`,
rather than the generic DIGIC VI offset `0x10`.

## Source change

`src/fio-ml.h` now has a `CONFIG_5D4`-specific `struct fio_file`.
It preserves the existing DIGIC VI mode, size and timestamp fields, inserts
eight unknown bytes before `name`, and therefore moves `name` to offset
`0x18`. Other DIGIC IV, V and VI layouts remain unchanged.

All temporary EXPO07 scan diagnostics were removed from `src/module.c` before
the final hardware validation. This checkpoint contains no `module.c` change.

## Hardware validation

With the 5D4-specific layout, the top-level Modules tab appeared and the
following module entries were enumerated:

- `bench`
- `dual_iso`
- `ettr`
- `file_man`

This is a causal hardware witness that the module enumeration failure came from
the 5D4 FIO directory-entry layout.

## Build provenance

The recovery build completed with `BUILD_RC=0`:

- artifact: `EXPO07-RECOVERED-autoexec.bin`
- size: `238912 bytes`
- SHA-256: `7a57b3c75660506d4ac4278868a5cf0593c9ea27296bee4c32524a08d58bb353`

The subsequent FIO candidate booted successfully and produced the hardware
enumeration result above. The recovery artifact is recorded as build evidence;
no generated binary is committed.

## Remaining validation

This is not yet a main milestone. Still required:

- broader FIO regression smoke testing;
- module load and unload validation;
- investigation of `CONFIG_TCC_UNLOAD` compatibility before enabling ETTR;
- functional ETTR testing.

No regression has been established, but the exact FIO candidate has not yet
received a broad regression pass. Freeze and Err70 status were not explicitly
recorded and are not inferred.

## Provenance and scope

Local development baseline: `5d4-133-candidate` commit
`77bfce0ff4b08b93e0ae6719a883f14ad2ab8a33`. This is provenance only; the
integration base is the current `research/expo` patch series.

Patch `0008-5D4.133-FIO-module-enumeration-HC1.patch` contains only the
5D4-specific FIO layout change. It excludes temporary diagnostics, ETTR
enablement, dirty-tree changes, generated binaries and Canon proprietary
material.

No merge to `main`, tag or release is implied.
