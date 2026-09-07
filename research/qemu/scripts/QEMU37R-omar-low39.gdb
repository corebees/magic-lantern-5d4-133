set pagination off
set confirm off
set architecture arm
set remotetimeout 15

target remote 127.0.0.1:1253

printf "\n[QEMU37R] REMOTE CONNECTED\n"


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

                printf "[QEMU37R] PROP_VIDEO_MODE differential applied\n"
                disable 1
            end
        end
    end

    continue
end


# ------------------------------------------------------------
# Omar-specific tail call:
#
# FE34D1F0 ldr  r0, =0x6364
# FE34D1F2 movs r3,#0
# FE34D1F4 ldr  r2, =FE34D1AD
# FE34D1F6 ldrh r1,[r0]
# FE34D1F8 adds r0,#4      => 0x6368
# FE34D1FA b.w  FE434B7A  => DryOS low 0x39
#
# Unlike FE434B7A, this address belongs uniquely to Omar.
# ------------------------------------------------------------

hbreak *0xFE34D1FA

commands
    silent

    printf "\n============================================================\n"
    printf "[QEMU37R-OMAR-LOW39]\n"
    printf "============================================================\n"

    printf "PC=%08x LR=%08x SP=%08x\n", $pc,$lr,$sp

    printf "\n===== EXACT ARGUMENTS TO LOW 0x39 =====\n"

    printf "r0 = %08x\n", $r0
    printf "r1 = %08x\n", $r1
    printf "r2 = %08x\n", $r2
    printf "r3 = %08x\n", $r3

    printf "\nExpected structural values:\n"
    printf "r0 ~= 00006368\n"
    printf "r1 == *(u16 *)00006364\n"
    printf "r2 ~= FE34D1AD\n"
    printf "r3 == 00000000\n"

    printf "\n===== SOURCE RAM =====\n"

    printf "[0x6364] = %04x\n", *(unsigned short*)0x6364
    x/4hx 0x6364

    printf "\n===== SLOT TABLE =====\n"
    x/5wx 0x28688

    printf "\n===== CURRENT INSTRUCTION =====\n"
    x/2i $pc

    printf "\n===== LOW 0x39 =====\n"
    x/24i 0x38

    printf "\n[QEMU37R] OMAR LOW39 TAILCALL REACHED\n"

    disable 2
    continue
end


printf "[QEMU37R] breakpoints armed\n"

continue
