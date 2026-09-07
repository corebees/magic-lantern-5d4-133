set pagination off
set confirm off
set architecture arm
set remotetimeout 15

target remote 127.0.0.1:1257

printf "\n[QEMU37V] REMOTE CONNECTED\n"

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
                printf "[QEMU37V] PROP_VIDEO_MODE differential applied\n"
                disable 1
            end
        end
    end

    continue
end


# ------------------------------------------------------------
# H3 midpoint.
#
# Reaching FE0DF208 proves these returned:
#
#   FE43525C
#   FE0E236A
#   FE0E2392
#
# Current instruction is the call to FE548436.
# ------------------------------------------------------------

hbreak *0xFE0DF208
commands
    silent

    printf "\n============================================================\n"
    printf "[QEMU37V-H3-MIDPOINT]\n"
    printf "============================================================\n"

    printf "PC=%08x LR=%08x SP=%08x\n", $pc,$lr,$sp
    printf "R0=%08x R1=%08x R2=%08x R3=%08x\n", \
        $r0,$r1,$r2,$r3

    printf "\n===== H3 START =====\n"
    x/24i 0xFE0DF1E6

    printf "\n[QEMU37V] H3 MIDPOINT REACHED\n"

    disable 2
    continue
end

printf "[QEMU37V] breakpoints armed\n"
continue
