.data
grades:     .space 20

msg_in:     .asciiz "Enter grade: "
msg_all:    .asciiz "\nGrades:\n"
msg_high:   .asciiz "\nHighest: "
msg_low:    .asciiz "\nLowest: "
msg_total:  .asciiz "\nTotal: "
msg_avg:    .asciiz "\nAverage: "
msg_pass:   .asciiz "\nPassed: "
msg_fail:   .asciiz "\nFailed: "
msg_letter: .asciiz "\nLetter Grades:\n"

.text
.globl main


main:
    la $a0, grades
    jal readGrades

    la $a0, grades
    jal printGrades

    la $a0, grades
    jal computeStats
    # computeStats results in -> v0 = high, v1 = low, s1 = total, s2 = pass, s3 =  fail

    move $a0, $v0
    move $a1, $v1
    move $a2, $s1
    move $a3, $s2
    jal printStats

    la $a0, grades
    jal letterGrades

    li $v0, 10
    syscall


readGrades:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $t0, 8($sp)
    sw $t1, 12($sp)

    move $s0, $a0
    li $t0, 0

readLoop:
    beq $t0, 5, readDone

    li $v0, 4
    la $a0, msg_in
    syscall

    li $v0, 5
    syscall
    sw $v0, 0($s0)

    addi $s0, $s0, 4
    addi $t0, $t0, 1
    j readLoop

readDone:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $t0, 8($sp)
    lw $t1, 12($sp)
    addi $sp, $sp, 16
    jr $ra


printGrades:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $t0, 8($sp)
    sw $t1, 12($sp)

    move $s0, $a0
    li $t0, 0

printLoop:
    beq $t0, 5, printDone

    lw $a0, 0($s0)
    li $v0, 1
    syscall

    li $v0, 11
    li $a0, 10
    syscall

    addi $s0, $s0, 4
    addi $t0, $t0, 1
    j printLoop

printDone:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $t0, 8($sp)
    lw $t1, 12($sp)
    addi $sp, $sp, 16
    jr $ra


# these are da results: v0 high, v1 low, s1 total, s2 pass, s3 fail
computeStats:
    addi $sp, $sp, -32
    sw $ra,  0($sp)
    sw $s0,  4($sp)
    sw $s1,  8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $t0, 20($sp)
    sw $t1, 24($sp)
    sw $t2, 28($sp)

    move $s0, $a0

    lw $t1, 0($s0) # high
    lw $t2, 0($s0) # low
    li $s1, 0 # total
    li $s2, 0 # pass
    li $s3, 0 # fail
    li $t0, 0

statsLoop:
    beq $t0, 5, statsDone

    lw $t6, 0($s0)
    add $s1, $s1, $t6

    ble $t6, $t1, skipHigh
    move $t1, $t6
skipHigh:

    bge $t6, $t2, skipLow
    move $t2, $t6
skipLow:

    blt $t6, 50, isFail
    addi $s2, $s2, 1
    j statNext
isFail:
    addi $s3, $s3, 1
statNext:

    addi $s0, $s0, 4
    addi $t0, $t0, 1
    j statsLoop

statsDone:
    move $v0, $t1
    move $v1, $t2

    lw $ra,  0($sp)
    lw $s0,  4($sp)
    # leave s1, s2, s3 so caller can read return vals
    lw $t0, 20($sp)
    lw $t1, 24($sp)
    lw $t2, 28($sp)
    addi $sp, $sp, 32
    
    jr $ra



# gets in deez args: a0 = high, a1 = low, a2 = total, a3 = pass, s3 = fail
printStats:
    addi $sp, $sp, -20
    sw $ra,  0($sp)
    sw $t0,  4($sp)
    sw $t1,  8($sp)
    sw $t2, 12($sp)
    sw $t3, 16($sp)

    move $t0, $a0 # high
    move $t1, $a1 # low
    move $t2, $a2 # total
    move $t3, $a3 # pass


    li $v0, 4
    la $a0, msg_high
    syscall
    move $a0, $t0
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, msg_low
    syscall
    move $a0, $t1
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, msg_total
    syscall
    move $a0, $t2
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, msg_avg
    syscall
    div $t2, $t2, 5
    mflo $t2
    move $a0, $t2
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, msg_pass
    syscall
    move $a0, $t3
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, msg_fail
    syscall
    move $a0, $s3
    li $v0, 1
    syscall


    lw $ra,  0($sp)
    lw $t0,  4($sp)
    lw $t1,  8($sp)
    lw $t2, 12($sp)
    lw $t3, 16($sp)
    addi $sp, $sp, 20
    jr $ra


letterGrades:
    addi $sp, $sp, -20
    sw $ra,  0($sp)
    sw $s0,  4($sp)
    sw $t0,  8($sp)
    sw $t1, 12($sp)
    sw $t2, 16($sp)

    move $s0, $a0
    li $t0, 0

    li $v0, 4
    la $a0, msg_letter
    syscall

letterLoop:
    beq $t0, 5, letterDone

    lw $t1, 0($s0)

    li $t2, 90
    bge $t1, $t2, isA
    li $t2, 80
    bge $t1, $t2, isB
    li $t2, 70
    bge $t1, $t2, isC
    li $t2, 60
    bge $t1, $t2, isD
    j isF

isA: li $a0, 'A'
    j printL
isB: li $a0, 'B'
    j printL
isC: li $a0, 'C'
    j printL
isD: li $a0, 'D'
    j printL
isF: li $a0, 'F'

printL:
    li $v0, 11
    syscall
    li $v0, 11
    li $a0, 10
    syscall

    addi $s0, $s0, 4
    addi $t0, $t0, 1
    j letterLoop

letterDone:
    lw $ra,  0($sp)
    lw $s0,  4($sp)
    lw $t0,  8($sp)
    lw $t1, 12($sp)
    lw $t2, 16($sp)
    addi $sp, $sp, 20
    jr $ra
