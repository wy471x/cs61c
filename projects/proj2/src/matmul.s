.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
#   The order of error codes (checked from top to bottom):
#   If the dimensions of m0 do not make sense, 
#   this function exits with exit code 2.
#   If the dimensions of m1 do not make sense, 
#   this function exits with exit code 3.
#   If the dimensions don't match, 
#   this function exits with exit code 4.
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# =======================================================
matmul:

    # Error checks
    li t0, 1
    blt a1, t0, exit_2
    blt a2, t0, exit_2
    blt a4, t0, exit_3
    blt a5, t0, exit_3
    #bne a1, a5, exit_4
    #bne a2, a4, exit_4

    # Prologue
    # init
    addi sp, sp, -16
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    li s0, 0
    li s1, 0

outer_loop_start:
   li s1, 0

inner_loop_start:
   addi sp, sp, -32
   sw a0, 0(sp)
   sw a1, 4(sp)
   sw a2, 8(sp)
   sw a3, 12(sp)
   sw a4, 16(sp)
   sw a5, 20(sp)
   sw a6, 24(sp)
   sw ra, 28(sp)

   addi t4, x0, 4
   mul t2, t4, s1
   add a1, a3, t2
   li a3, 1
   mv a4, a5
   jal dot
   mv t1, a0
   lw a0, 0(sp)
   lw a1, 4(sp)
   lw a2, 8(sp)
   lw a3, 12(sp)
   lw a4, 16(sp)
   lw a5, 20(sp)
   lw a6, 24(sp)
   lw ra, 28(sp)
   addi sp, sp, 32

   mul t2, s0, a5
   add t2, t2, s1
   addi t4, x0, 4
   mul t2, t2, t4
   add t2, a6, t2
   sw t1, 0(t2)

inner_loop_end:
   addi s1, s1, 1
   beq s1, a5, outer_loop_end
   j inner_loop_start

outer_loop_end:
    # Epilogue
    addi s0, s0, 1
    addi t4, x0, 4
    mul t0, t4, a2
    add a0, a0, t0
    beq s0, a1, end
    j outer_loop_start

end:
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    addi sp, sp, 16
    ret

exit_2:
   li a1, 2
   j exit2

exit_3:
   li a1, 3
   j exit2

exit_4:
   li a1, 4
   j exit2