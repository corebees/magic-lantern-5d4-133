set pagination off
set confirm off
set architecture arm
set remotetimeout 15

target remote 127.0.0.1:1252

printf "\n[QEMU37Q] REMOTE CONNECTED\n"


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

                printf "[QEMU37Q] PROP_VIDEO_MODE differential applied\n"
                disable 1
            end
        end
    end

    continue
end


# ------------------------------------------------------------
# FE34D1E0 -> FE434B7A -> DryOS low entry 0x39
# ------------------------------------------------------------

hbreak *0xFE434B7A

commands
    silent

    printf "\n============================================================\n"
    printf "[QEMU37Q-LOW39-HANDOFF]\n"
    printf "============================================================\n"

    printf "PC=%08x LR=%08x SP=%08x\n", $pc,$lr,$sp

    printf "\n===== CALL ARGUMENTS =====\n"
    printf "r0 = %08x\n", $r0
    printf "r1 = %08x\n", $r1
    printf "r2 = %08x\n", $r2
    printf "r3 = %08x\n", $r3

    printf "\n===== OMAR RAM =====\n"
    printf "[0x6364] halfword = %04x\n", *(unsigned short*)0x6364
    x/4hx 0x6364

    printf "\n===== SLOT TABLE 0x28688 =====\n"
    x/5wx 0x28688

    printf "\n===== CALLBACK FE34D1AC =====\n"
    x/16i 0xFE34D1AC

    printf "\n===== DRYOS LOW ENTRY 0x39 =====\n"
    printf "Thumb entry = 00000039\n"
    printf "Code        = 00000038\n"

    printf "\n-- raw halfwords --\n"
    x/32hx 0x38

    printf "\n-- instructions --\n"
    x/40i 0x38

    printf "\n[QEMU37Q] LOW39 HANDOFF CONFIRMED\n"

    disable 2
    continue
end


printf "[QEMU37Q] breakpoints armed\n"

continue
