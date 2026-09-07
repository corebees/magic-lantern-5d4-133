set pagination off
set confirm off
set architecture arm
set remotetimeout 15

target remote 127.0.0.1:1256

printf "\n[QEMU37U] REMOTE CONNECTED\n"


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

                printf "[QEMU37U] PROP_VIDEO_MODE differential applied\n"
                disable 1
            end
        end
    end

    continue
end


# ------------------------------------------------------------
# H3 path immediately before FE43525C
#
# FE0DF3CC movs r1,#6
# FE0DF3CE movs r0,#139
# FE0DF3D0 add  r2,pc,#1016
# FE0DF3D2 blx  FE43525C   <-- HERE
# FE0DF3D6 movs r0,#0
# ------------------------------------------------------------

hbreak *0xFE0DF3D2
commands
    silent

    printf "\n============================================================\n"
    printf "[QEMU37U-FE43525C-CALLSITE]\n"
    printf "============================================================\n"

    printf "PC=%08x LR=%08x SP=%08x\n", $pc,$lr,$sp
    printf "R0=%08x R1=%08x R2=%08x R3=%08x\n", \
        $r0,$r1,$r2,$r3

    printf "\n===== CALLSITE =====\n"
    x/12i 0xFE0DF3C8

    printf "\n===== R2 TARGET / DATA =====\n"
    x/8wx $r2

    printf "\n[QEMU37U] FE43525C CALLSITE REACHED\n"

    disable 2
    continue
end

printf "[QEMU37U] breakpoints armed\n"
continue
