set pagination off
set confirm off
set architecture arm
set remotetimeout 15

target remote 127.0.0.1:1254

printf "\n[QEMU37S] REMOTE CONNECTED\n"


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

                printf "[QEMU37S] PROP_VIDEO_MODE differential applied\n"
                disable 1
            end
        end
    end

    continue
end


# ------------------------------------------------------------
# OmarSysInit:
#
# FE0E25C2 BLX FE4350B4
# ...
# FE0E25CE STR 0xFFFFFFFF -> [0xD209B080]
#
# FE0E25D0 BLX FE4350AC   <-- breakpoint HERE
#
# Reaching D0 proves:
#   1) critical-enter FE4350B4 returned
#   2) MMIO write instruction completed
# ------------------------------------------------------------

hbreak *0xFE0E25D0

commands
    silent

    printf "\n============================================================\n"
    printf "[QEMU37S-BEFORE-CRITICAL-LEAVE]\n"
    printf "============================================================\n"

    printf "PC=%08x LR=%08x SP=%08x\n", $pc,$lr,$sp
    printf "R0=%08x R1=%08x R2=%08x R3=%08x\n", \
        $r0,$r1,$r2,$r3

    printf "\n===== INSTRUCTIONS =====\n"
    x/8i 0xFE0E25C2

    printf "\n===== MMIO TARGET =====\n"
    printf "D209B080 = %08x\n", *(unsigned int*)0xD209B080

    printf "\n[QEMU37S] PRE-LEAVE REACHED\n"

    disable 2
    continue
end


printf "[QEMU37S] breakpoints armed\n"

continue
