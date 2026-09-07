set pagination off
set confirm off
set architecture arm
set remotetimeout 15

target remote 127.0.0.1:1261

printf "\n[QEMU37Z] REMOTE CONNECTED\n"


# ------------------------------------------------------------
# PROP_VIDEO_MODE differential
# ------------------------------------------------------------

hbreak *0xFE2C17F2
commands
    silent

    set $prop = *(unsigned int*)($r5+0)
    set $src  = *(unsigned int*)($r5+4)
    set $len  = *(unsigned int*)($r5+8)

    if $prop == 0x80000039
        if $len == 0x20
            if *(unsigned int*)($src+8) == 0x51

                set *(unsigned int*)($src+4) = 0
                set *(unsigned int*)($src+8) = 2997

                printf "[QEMU37Z] PROP_VIDEO_MODE differential applied\n"
                disable 1
            end
        end
    end

    continue
end


# ------------------------------------------------------------
# Exact instruction immediately after:
#
# FE0E2378 BLX FE4351FC -> take_semaphore
# FE0E237C LSLS r0,r0,#31
#
# If this breakpoint is reached, take_semaphore returned.
# ------------------------------------------------------------

hbreak *0xFE0E237C
commands
    silent

    printf "\n============================================================\n"
    printf "[QEMU37Z-TAKE-SEMAPHORE-RETURN]\n"
    printf "============================================================\n"

    printf "PC=%08x LR=%08x SP=%08x\n", $pc,$lr,$sp

    printf "\n===== RETURN VALUE =====\n"
    printf "r0 = %08x\n", $r0
    printf "r0 bit0 = %u\n", ($r0 & 1)

    printf "\n===== OTHER REGISTERS =====\n"
    printf "r1=%08x r2=%08x r3=%08x\n", $r1,$r2,$r3

    printf "\n===== LOCAL CODE =====\n"
    x/16i 0xFE0E236A

    printf "\nInterpretation of following instructions:\n"
    printf "FE0E237C LSLS r0,r0,#31\n"
    printf "FE0E237E BEQ  FE0E2390\n"
    printf "bit0=0 -> normal return branch\n"
    printf "bit0=1 -> error/tail path\n"

    printf "\n[QEMU37Z] TAKE_SEMAPHORE RETURNED\n"

    disable 2
    continue
end


printf "[QEMU37Z] breakpoints armed\n"
continue
