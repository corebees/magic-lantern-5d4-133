set pagination off
set confirm off
set architecture arm
set remotetimeout 15

target remote 127.0.0.1:1255

printf "\n[QEMU37T] REMOTE CONNECTED\n"


# PROP_VIDEO_MODE differential
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

                printf "[QEMU37T] PROP_VIDEO_MODE differential applied\n"
                disable 1
            end
        end
    end

    continue
end


# ------------------------------------------------------------
# Exact OmarSysInit entry.
#
# Caller:
# FE0DF3E2 -> FE0E25C0
# ------------------------------------------------------------

hbreak *0xFE0E25C0
commands
    silent

    printf "\n============================================================\n"
    printf "[QEMU37T-OMAR-ENTRY]\n"
    printf "============================================================\n"

    printf "PC=%08x LR=%08x SP=%08x\n", $pc,$lr,$sp
    printf "R0=%08x R1=%08x R2=%08x R3=%08x\n", \
        $r0,$r1,$r2,$r3

    printf "\n===== OMAR ENTRY =====\n"
    x/18i 0xFE0E25C0

    printf "\n===== CALLER =====\n"
    x/16i 0xFE0DF3C8

    printf "\n[QEMU37T] OMARSYSINIT ENTRY REACHED\n"

    disable 2
    continue
end


printf "[QEMU37T] breakpoints armed\n"

continue
