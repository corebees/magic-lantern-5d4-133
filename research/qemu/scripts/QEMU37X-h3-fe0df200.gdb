set pagination off
set confirm off
set architecture arm
set remotetimeout 15

target remote 127.0.0.1:1259

printf "\n[QEMU37X] REMOTE CONNECTED\n"


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

                printf "[QEMU37X] PROP_VIDEO_MODE differential applied\n"
                disable 1
            end
        end
    end

    continue
end


# ------------------------------------------------------------
# H3 decisive split
#
# FE0DF1F0 -> FE43525C
#
# FE0DF200 -> FE0E236A   <-- breakpoint HERE
#
# FE0DF204 -> FE0E2392   QEMU37W says NOT reached
#
# Reaching FE0DF200 proves FE43525C returned.
# ------------------------------------------------------------

hbreak *0xFE0DF200
commands
    silent

    printf "\n============================================================\n"
    printf "[QEMU37X-H3-FE0DF200]\n"
    printf "============================================================\n"

    printf "PC=%08x LR=%08x SP=%08x\n", $pc,$lr,$sp
    printf "R0=%08x R1=%08x R2=%08x R3=%08x\n", \
        $r0,$r1,$r2,$r3

    printf "\n===== LOCAL H3 CONTEXT =====\n"
    x/20i 0xFE0DF1E6

    printf "\n===== FE0E236A TARGET =====\n"
    x/30i 0xFE0E236A

    printf "\n[QEMU37X] FE0DF200 REACHED\n"

    disable 2
    continue
end


printf "[QEMU37X] breakpoints armed\n"
continue
