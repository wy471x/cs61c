.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
#   If any file operation fails or doesn't write the proper number of bytes,
#   exit the program with exit code 1.
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
#
# If you receive an fopen error or eof, 
# this function exits with error code 53.
# If you receive an fwrite error or eof,
# this function exits with error code 54.
# If you receive an fclose error or eof,
# this function exits with error code 55.
# ==============================================================================
write_matrix:

    # Prologue
    addi sp, sp, -36
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw ra, 32(sp)

    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3

    # fopen: get file descriptor [t0]
    mv a1, s0
    li a2, 1
    jal fopen
    blt a0, x0, exit_64
    mv s5, a0

    addi  sp, sp, -4
    sw s2, 0(sp)
    mv a1, s5
    mv a2, sp
    li a3, 1
    li a4, 4
    jal fwrite
    blt a0, x0, exit_67

    sw s3, 0(sp)
    mv a1, s5
    mv a2, sp
    li a3, 1
    li a4, 4
    jal fwrite
    blt a0, x0, exit_67
    addi sp, sp, 4

    li s6, 0
    mul s7, s2, s3

loop_start:
    mv a1, s5
    slli t0, s6, 2
    add t0, s1, t0
    mv a2, t0

    mv a3, s7
    li a4, 4
    jal fwrite
    blt a0, x0, exit_67
    add s6, s6, a0
    bne s6, s7, loop_start

    # fflush
    mv a0, s5
    jal fflush
    bne a0, x0, exit_65

    # close
    mv a1, s5
    jal fclose
    blt a0, zero, exit_65

    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw ra, 32(sp)
    addi sp, sp, 36

    # Epilogue
    ret

exit_64:
    li a1, 64
    j exit2

exit_65:
    li a1, 65
    j exit2

exit_67:
    li a1, 67
    j exit2