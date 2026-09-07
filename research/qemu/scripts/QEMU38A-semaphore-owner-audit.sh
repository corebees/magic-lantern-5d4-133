#!/usr/bin/env bash
set -euo pipefail

ROM="$HOME/qemu-eos/roms/5D4/ROM1.BIN"
OBJDUMP="$(command -v arm-none-eabi-objdump)"

echo "============================================================"
echo " QEMU38A — SEMAPHORE OWNER / CREATION STATIC AUDIT"
echo "============================================================"

echo
echo "===== ROM ====="
stat -c '%n  %s bytes' "$ROM"
sha256sum "$ROM"

echo
echo "===== KNOWN DRYOS LOW SYMBOLS ====="
echo "0x01D1 -> create_named_semaphore"
echo "0x0297 -> take_semaphore_now"
echo "0x02C7 -> take_semaphore"
echo "0x033F -> give_semaphore"

echo
echo "===== ARM VENEERS TO SEMAPHORE PRIMITIVES ====="

python3 - "$ROM" <<'PY'
import struct
import sys

rom = open(sys.argv[1], "rb").read()
BASE = 0xFE000000

targets = {
    0x000001D1: "create_named_semaphore",
    0x00000297: "take_semaphore_now",
    0x000002C7: "take_semaphore",
    0x0000033F: "give_semaphore",
}

found = {x: [] for x in targets}

# Canon ARM veneers used in this region:
# E51FF004
# <literal target>
for off in range(0, len(rom) - 8, 4):
    insn, literal = struct.unpack_from("<II", rom, off)

    if insn == 0xE51FF004 and literal in targets:
        found[literal].append(BASE + off)

for target, name in targets.items():
    print(f"{name:24s} low={target:08X}")
    if found[target]:
        for addr in found[target]:
            print(f"    veneer = {addr:08X}")
    else:
        print("    veneer = NOT FOUND")
PY

echo
echo "===== ALL RAW REFERENCES TO GLOBAL 0x00004ACC ====="

python3 - "$ROM" <<'PY'
import struct
import sys

rom = open(sys.argv[1], "rb").read()
BASE = 0xFE000000
needle = struct.pack("<I", 0x00004ACC)

hits = []
start = 0
while True:
    off = rom.find(needle, start)
    if off < 0:
        break
    hits.append(off)
    start = off + 1

print("count =", len(hits))
for off in hits:
    print(f"ROM+0x{off:08X}  runtime={BASE+off:08X}")
PY

echo
echo "===== TARGET SUBSYSTEM FE0E2200-FE0E2600 ====="

"$OBJDUMP" \
    -D \
    -b binary \
    -marm \
    -Mforce-thumb \
    --adjust-vma=0xFE000000 \
    --start-address=0xFE0E2200 \
    --stop-address=0xFE0E2600 \
    "$ROM"

echo
echo "===== LITERAL POOL / RAW WORDS FE0E24C0-FE0E2540 ====="

python3 - "$ROM" <<'PY'
import struct
import sys

rom = open(sys.argv[1], "rb").read()
BASE = 0xFE000000

start = 0xFE0E24C0
end   = 0xFE0E2540

for addr in range(start, end, 4):
    off = addr - BASE
    val = struct.unpack_from("<I", rom, off)[0]
    print(f"{addr:08X}: {val:08X}")
PY

echo
echo "===== ASCII STRINGS NEAR SUBSYSTEM ====="

python3 - "$ROM" <<'PY'
import sys

rom = open(sys.argv[1], "rb").read()
BASE = 0xFE000000

lo = 0xFE0E2000 - BASE
hi = 0xFE0E2800 - BASE
data = rom[lo:hi]

i = 0
while i < len(data):
    if 32 <= data[i] <= 126:
        j = i
        while j < len(data) and 32 <= data[j] <= 126:
            j += 1

        if j - i >= 4:
            text = data[i:j].decode("ascii", errors="replace")
            print(f"{BASE+lo+i:08X}: {text}")

        i = j
    else:
        i += 1
PY

echo
echo "QEMU38A STATIC AUDIT COMPLETE"
