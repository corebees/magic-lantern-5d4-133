set pagination off
set confirm off
set architecture arm
set remotetimeout 15

target remote 127.0.0.1:1262

printf "\n[QEMU38B] REMOTE CONNECTED\n"


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

                printf "[QEMU38B] PROP_VIDEO_MODE differential applied\n"
                disable 1
            end
        end
    end

    continue
end


# ------------------------------------------------------------
# Omar completion/release routine.
#
# FE0E24BE
#   FE0E75C8
#   FE58108C
#   FE633B4C
#   give_semaphore(r4->+8)
# ------------------------------------------------------------

hbreak *0xFE0E24BE
commands
    silent

    printf "\n============================================================\n"
    printf "[QEMU38B-OMAR-COMPLETION-ENTRY]\n"
    printf "============================================================\n"

    printf "PC=%08x LR=%08x SP=%08x\n", $pc,$lr,$sp

    printf "\n===== ARGUMENT =====\n"
    printf "r0 = %08x\n", $r0

    if $r0 != 0
        printf "\n===== OBJECT =====\n"
        x/12wx $r0

        printf "\nobject+8 semaphore = %08x\n", \
            *(unsigned int*)($r0+8)
    end

    printf "\n===== COMPLETION CODE =====\n"
    x/20i 0xFE0E24BE

    printf "\n[QEMU38B] OMAR COMPLETION ENTRY REACHED\n"

    disable 2
    continue
end


printf "[QEMU38B] breakpoints armed\n"
continue
