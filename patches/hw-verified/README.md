# Hardware-verified patch series

This directory contains the clean Git commits recovered from the hardware-tested 5D4.133 source tree.

## Base

Apply the series on top of:

- upstream repository: `reticulatedpines/magiclantern_simplified`
- upstream branch at the time of the work: `dev`
- base commit: `cb1783df8` (`mlv_lite: avoid shadowing fps var`)
- verified series tip: `77bfce0ff4b08b93e0ae6719a883f14ad2ab8a33`

## Apply

```sh
git checkout -b 5d4-133-port cb1783df8
git am patches/hw-verified/*.patch
```

## Hardware checkpoints

| Original tag | Commit | Scope |
|---|---|---|
| `5d4-133-hw-good-20260829` | `a8ff01f13` | Boot/GUI/LiveView/RGBA/Canon OSD path |
| `5d4-133-menu-hw-good-20260829` | `bac4a32e2` | ML menu input and RGBA redraw |
| `5d4-133-gui-hw-good-20260829` | `77bfce0ff` | ML menu remains available in LiveView |

These patches preserve their original author metadata and commit messages. They contain no Canon FIR, ROM, SFDATA, dumps, generated camera binaries, or private test archives.

The later dirty working tree is intentionally not folded into this verified series: it combines working Zebra/DispVram work with diagnostic code and later GUI experiments that produced freezes or Err 70. It will be published separately only after a source-level split.
