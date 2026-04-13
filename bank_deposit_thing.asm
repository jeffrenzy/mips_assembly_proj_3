.data
msg_dep:   .asciiz "Enter initial deposit: "
msg_rate:  .asciiz "Enter annual interest rate (e.g. 0.05): "
msg_out:   .asciiz "\nFinal balance after 3 years: "

one: .float 1.0

.text
.globl main

main:
    jal readInput
    jal computeBalance
    jal printResult

    li $v0, 10
    syscall

readInput:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    s.s $f0, 4($sp)
    s.s $f2, 8($sp)

    # read deposit
    li $v0, 4
    la $a0, msg_dep
    syscall

    li $v0, 6
    syscall
    mov.s $f2, $f0  # save deposit into $f2

    # read rate
    li $v0, 4
    la $a0, msg_rate
    syscall

    li $v0, 6
    syscall
    mov.s $f1, $f0 # rate in $f1

    mov.s $f0, $f2 # move deposit back to $f0

    lw $ra, 0($sp)
    # dont reset f0 and f2 so caller can read them
    addi $sp, $sp, 12
    jr $ra

computeBalance:
    addi $sp, $sp, -24
    sw $ra,   0($sp)
    s.s $f3, 4($sp)
    s.s $f4, 8($sp)
    s.s $f5, 12($sp)
    s.s $f6, 16($sp)
    s.s $f2, 20($sp)

    # load 1.0
    l.s $f3, one 

    # (1 + rate)
    add.s $f4, $f3, $f1

    # square dis
    mul.s $f5, $f4, $f4

    # cube dis
    mul.s $f6, $f5, $f4

    # final result
    mul.s $f2, $f0, $f6

    lw $ra, 0($sp)
    lw $ra, 0($sp)
    l.s $f3, 4($sp)
    l.s $f4, 8($sp)
    l.s $f5, 12($sp)
    l.s $f6, 16($sp)
    # we dont reset f2 cause its used as a return val
    addi $sp, $sp, 24
    jr $ra

printResult:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    s.s $f12, 4($sp)

    li $v0, 4
    la $a0, msg_out
    syscall

    mov.s $f12, $f2
    li $v0, 2
    syscall

    lw $ra, 0($sp)
    l.s $f12, 4($sp)
    addi $sp, $sp, 8
    jr $ra
