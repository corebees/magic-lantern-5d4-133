# 5D4 QEMU post-PAD-AD frontier index

Status: **RESEARCH UPDATE / QEMU AND STATIC REVERSE ENGINEERING**  
Firmware target: **Canon EOS 5D Mark IV 1.3.3**  
qemu-eos baseline: `4b667a1d3c08ab7a55835d15ddbd884fa754946d`

## Boundary

The last published executable source checkpoint is PAD-AD: a synthetic,
checksum-valid EDID delivered through Canon's natural CH2 slave-`0x7C`
receive path. Canon completes both 64-byte reads, reports EDID success and
continues into Movie, VRAM, HDR, TouchPanel and GUI initialization.

Work after PAD-AD is retained as research evidence rather than an integrated
source patch. The experimental tree mixes causal witnesses with extensive
logging and cannot be reviewed or reproduced as one implementation.

## Post-PAD-AD investigation map

| Area | Test family | Current evidence | Classification |
|---|---|---|---|
| Deferred startup/MZRM | QEMU40PAD-BB | Preserved workcard continues analysis beyond the PAD-AD startup frontier | Research evidence |
| GUI/display delivery | QEMU40PAD-BC R20EA–R20EH | Display-control delivery, refresh/rearm and wake paths were instrumented | Diagnostic only |
| Event 21 and dispatcher | R20DM-R2, R20EA–R20FP | Completion/wait witnesses and dispatcher/caller context were traced | Partial causal evidence |
| Queue/scheduler state | R20FQ–R20GP | Ring, ready/wait, dequeue, restore and scheduling state were compared | Diagnostic frontier |
| SIO3 source selection | R20GW–R20GY | Active/pending/next sources and IRQ scheduling were instrumented | Unresolved |
| R20GY output | R20GY/R20GZ audit | Principal logs grew to about 403 MB each | Invalid for behavior verdict |

This index records research direction, not success of every enumerated probe.
Global startup completion and a faithful Canon GUI remain unproven.

## Source triage

Current tracked delta against the qemu-eos baseline:

| File | Added | Removed |
|---|---:|---:|
| `accel/tcg/cputlb.c` | 26 | 0 |
| `hw/eos/dbi/logging.c` | 6,858 | 0 |
| `hw/eos/engine.c` | 2 | 1 |
| `hw/eos/eos.c` | 3,791 | 119 |
| `hw/eos/model_list.c` | 23 | 0 |
| `hw/eos/mpu.c` | 10 | 0 |
| **Total** | **10,710** | **120** |

The complete tracked diff is archived with SHA-256
`efaff28354ba9d65b44db8be7aa1a091843df5088b7d6ed5cd829f7f11bc68a0`.
The separate untracked `hw/eos/mpu_spells/5D4.h` candidate is archived with
SHA-256
`97ea1c1a585427377ce21c590bf72b09a05fd4d16d92441e46bc13dc8af5ad66`.

Neither artifact is published here. The tracked diff is dominated by temporary
diagnostics, while the MPU spell file mixes multiple causal probes and
synthetic responses that are not established as genuine 5D4 semantics.

## Integration rule

Future QEMU source checkpoints should:

1. start from the clean qemu-eos baseline or a clearly declared published
   checkpoint;
2. extract one minimal causal behavior at a time;
3. remove or gate verbose logging;
4. preserve before/after hashes and an applicable patch;
5. rerun the focused QEMU test after cleanup;
6. avoid publishing ROMs, generated binaries, raw logs or workcards.

No physical-camera behavior is inferred from this research.
