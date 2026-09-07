set pagination off
set confirm off
set architecture arm
set remotetimeout 15

target remote 127.0.0.1:1260

printf "\n[QEMU37Y] REMOTE CONNECTED\n"


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

                printf "[QEMU37Y] PROP_VIDEO_MODE differential applied\n"
                disable 1
            end
        end
    end

    continue
end


# ------------------------------------------------------------
# FE0E236A:
#
#   ldr r0,[global]
#   ldr r0,[r0,#8]
#   if NULL -> return
#   ldr r0,[r0,#8]
#   mov r1,#0
#
# FE0E2378:
#   BLX FE4351FC = take_semaphore
#
# At this point:
#   r0 = semaphore handle
#   r1 = 0
# ------------------------------------------------------------

hbreak *0xFE0E2378
commands
    silent

    printf "\n============================================================\n"
    printf "[QEMU37Y-TAKE-SEMAPHORE]\n"
    printf "============================================================\n"

    printf "PC=%08x LR=%08x SP=%08x\n", $pc,$lr,$sp

    printf "\n===== TAKE_SEMAPHORE ARGUMENTS =====\n"
    printf "semaphore / r0 = %08x\n", $r0
    printf "timeout   / r1 = %08x\n", $r1
    printf "r2 = %08x\n", $r2
    printf "r3 = %08x\n", $r3

    printf "\n===== GLOBAL CHAIN =====\n"

    set $global = *(unsigned int*)0xFE0E24E8
    printf "literal FE0E24E8 = %08x\n", $global

    if $global != 0
        printf "[global] structure:\n"
        x/8wx $global

        set $obj = *(unsigned int*)($global+8)
        printf "global+8 object = %08x\n", $obj

        if $obj != 0
            printf "[object] structure:\n"
            x/12wx $obj

            set $sem = *(unsigned int*)($obj+8)
            printf "object+8 semaphore = %08x\n", $sem
        end
    end

    printf "\n===== SEMAPHORE OBJECT =====\n"

    if $r0 != 0
        x/16wx $r0
    end

    printf "\n===== LOCAL CODE =====\n"
    x/20i 0xFE0E236A

    printf "\n===== DRYOS VENEER =====\n"
    x/4wx 0xFE4351FC

    printf "\n[QEMU37Y] TAKE_SEMAPHORE CALL REACHED\n"

    disable 2
    continue
end


printf "[QEMU37Y] breakpoints armed\n"
continue
