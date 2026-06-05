# Digitube test program for Minisys-1 Experiment 2
# Tests 7-segment display at base address 0xFFFFFC80
#
# IO address map:
#   0xFFFFFC60-0xFFFFFC6F: LED (24-bit)
#   0xFFFFFC70-0xFFFFFC7F: Switch (24-bit)
#   0xFFFFFC80-0xFFFFFC8F: Digitube (16-bit: 2 x 4-bit digits)

.data 0x0000
        DELAY:  .word 0x0003F9409          # delay counter (~0.5s)
        PATTERN:.word 0x00000012           # display pattern: digit1=1, digit0=2

.text 0x0000
start:
        # Initialize registers
        ori $at, $zero, 1
        ori $v0, $zero, 2
        ori $v1, $zero, 3
        ori $a0, $zero, 4
        ori $a1, $zero, 5
        ori $a2, $zero, 6
        ori $a3, $zero, 7
        ori $t0, $zero, 8
        ori $t1, $zero, 9
        ori $t2, $zero, 10
        ori $t3, $zero, 11
        ori $t4, $zero, 12
        ori $t5, $zero, 13
        ori $t6, $zero, 14
        ori $t7, $zero, 15
        ori $s0, $zero, 16
        ori $s1, $zero, 17
        ori $s2, $zero, 18
        ori $s3, $zero, 19
        ori $s4, $zero, 20
        ori $s5, $zero, 21
        ori $s6, $zero, 22
        ori $s7, $zero, 23
        ori $t8, $zero, 24
        ori $t9, $zero, 25
        ori $i0, $zero, 26
        ori $i1, $zero, 27
        ori $s9, $zero, 28
        ori $sp, $zero, 29
        ori $s8, $zero, 30
        ori $ra, $zero, 31

        # Basic ALU test
        lw $v0, PATTERN($zero)
        addi $v0, $v0, 1

        # Digitube display loop: write incrementing values to 0xFFFFFC80
        lui $28, 0xFFFF                 # $28 = 0xFFFF0000 (IO base high 16 bits)
        ori $28, $28, 0xF000            # $28 = 0xFFFFF000 (IO base high 20 bits)
        ori $s0, $zero, 0               # counter = 0

disp_loop:
        # Write low 8 bits to digitube: digit0 = counter[3:0], digit1 = counter[7:4]
        sw $s0, 0xC80($28)              # write to 0xFFFFFC80

        # Delay
        jal delay_proc

        # Increment counter (0x00 → 0xFF)
        addi $s0, $s0, 1
        j disp_loop

delay_proc:
        lw $29, DELAY($zero)            # load delay count
dlop:
        addi $29, $29, -1
        bne $29, $0, dlop
        jr $31
