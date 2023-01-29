.import ../../src/read_matrix.s
.import ../../src/utils.s

.data
file_path: .asciiz "inputs/test_read_matrix/test_input.bin"

.text
main:
    # Read matrix into memory
    addi a0 x0 4
    call malloc
    add s0 a0 x0

    addi a0 x0 4
    call malloc
    add s1 a0 x0

    la a0 file_path
    add a1 s0 x0
    add a2 s1 x0
    call read_matrix
    add s5 a0 x0

    # Print out elements of matrix
    #lw a1 0(s0)
    #call print_int
    #addi a1 x0 ' '
    #call print_char
    #lw a1 0(s1)
    #call print_int
    #addi a1 x0 '\n'
    #call print_char

    add s2 x0 x0

print_outer_loop:
    lw t0 0(s0)
    bge s2 t0 finish
    lw t0 0(s1)
    mul t0 s2 t0
    addi t1 x0 4
    mul s4 t0 t1
    add s4 s5 s4
    add s3 x0 x0

print_inner_loop:
    lw t0, 0(s1)
    bge s3 t0 finish_inner_loop
    addi t1 x0 4
    mul t0 s3 t1
    add t0 s4 t0
    lw a1 0(t0)
    call print_int
    addi a1 x0 ' '
    call print_char
    addi s3 s3 1
    j print_inner_loop

finish_inner_loop:
    addi a1 x0 '\n'
    call print_char
    addi s2 s2 1
    j print_outer_loop

finish:
    # Terminate the program
    addi a0 x0 10
    ecall
