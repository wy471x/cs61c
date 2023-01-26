.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # 
    # If there are an incorrect number of command line args,
    # this function returns with exit code 49.
    #
    # Usage:
    #   main.s -m -1 <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>






	# =====================================
    # LOAD MATRICES
    # =====================================
    addi sp, sp, -52
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)
    sw s9, 40(sp)
    sw s10, 44(sp)
    sw s11, 48(sp)

    # check correct number of command line args
    li t0, 5
    bne a0, t0, incorrect_arg

    # init
    mv s0, a0
    mv s1, a1
    mv s2, a2

    # Load pretrained m0
    li a0, 8
    jal malloc

    beq a0, x0, malloc_error
    mv s3, a0

    lw a0, 4(s1)
    mv a1, s3
    addi a2, s3, 4

    jal read_matrix
    mv s4, a0

    # Load pretrained m1
    li a0, 8
    jal malloc

    beq a0, x0, malloc_error
    mv s6, a0

    lw a0, 8(s1)
    mv a1, s6
    addi a2, s6, 4

    jal read_matrix
    mv s7, a0

    # Load input matrix
    li a0, 8
    jal malloc

    beq a0, x0, malloc_error
    mv s9, a0

    lw a0, 12(s1)
    mv a1, s9
    addi a2, s9, 4

    jal read_matrix
    mv s10, a0

    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)

    # LINEAR LAYER: m0 * input
    lw a1, 0(s3) # load rows
    lw a2, 4(s3) # load cols

    mv a3, s10
    lw a4, 0(s9)
    lw a5, 4(s9)

    # size of the m0 * input matrix
    mul t0, a1, a5
    # create m0 * input matrix
    slli a0, t0, 2
    addi sp, sp, -20
    sw a1, 0(sp)
    sw a2, 4(sp)
    sw a3, 8(sp)
    sw a4, 12(sp)
    sw a5, 16(sp)
    jal malloc
    lw a5, 16(sp)
    lw a4, 12(sp)
    lw a3, 8(sp)
    lw a2, 4(sp)
    lw a1, 0(sp)
    addi sp, sp, 20

    beq a0, x0, malloc_error
    mv s8, a0 # free malloc later

    mv a6, a0
    mv a0, s4 # load m0 matrix pointer

    addi sp, sp, -4
    sw a6, 0(sp)
    jal matmul
    lw a6, 0(sp)
    addi sp, sp, 4

    mv t0, a6
    lw t1, 0(s3)
    lw t2, 4(s9)

    # NONLINEAR LAYER: ReLU(m0 * input)
    mv a0, t0
    mul a1, t1, t2

    addi sp, sp, -12
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)
    jal relu
    lw t2, 8(sp)
    lw t1, 4(sp)
    lw t0, 0(sp)
    addi sp, sp , 12

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
    lw a1, 0(s6)  # load m1 # of rows
    lw a2, 4(s6) # load m1 # of cols

    mv a3, t0 # load ReLU(m0 * input) matrix pointer
    mv a4, t1 # load # of rows
    mv a5, t2 # load # of cols

    mul t1, a1, a5 # size of the m1 * ReLU(m0 * input)
    # create m0 * input matrix
    slli a0, t1, 2 # create heap space

    addi sp, sp, -28
    sw t0, 0(sp) # store the pointer to ReLU(m0 * input)
    sw t1, 4(sp) # store the size of the m1 * ReLU(m0 * input)
    sw a1, 8(sp)
    sw a2, 12(sp)
    sw a3, 16(sp)
    sw a4, 20(sp)
    sw a5, 24(sp)
    jal malloc
    lw a5, 24(sp)
    lw a4, 20(sp)
    lw a3, 16(sp)
    lw a2, 12(sp)
    lw a1, 8(sp)
    lw t1, 4(sp)
    lw t0, 0(sp)
    addi sp, sp, 28

    beq a0, x0, malloc_error
    mv s0, a0 # recycle s0
    mv a6, a0 #need to free malloc at some point usually after inference
    mv a0, s7 # load the pointer to m1

    addi sp, sp, -16
    sw t1, 0(sp)
    sw a1, 4(sp)
    sw a5, 8(sp)
    sw a6, 12(sp)
    jal matmul
    lw a6, 12(sp)
    lw a5, 8(sp)
    lw a1, 4(sp)
    lw t1, 0(sp)
    addi sp, sp, 16

    # ====================================
    # WRITE FILE
    # ====================================
    lw a0, 16(s1)
    mv a2, a1
    mv a3, a5
    mv a1, a6
    # mv a1, a0
    # jal print_str

    addi sp, sp, -8
    sw t1, 0(sp)
    sw a1, 4(sp)
    jal write_matrix
    lw a1, 4(sp)
    lw t1, 0(sp)
    addi sp, sp, 8

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax

    mv a0, a1 #pointer to the start of the vector
    mv a1, t1 #size of the elements

    jal argmax
    mv s11, a0

    # Print classification
    bne s2, x0, done
    mv a1, s11
    jal print_int

    # Print newline afterwards for clarity
    li a1, '\n'
    jal print_char

    # =====================================
    # FREE MALLOC
    # =====================================
    mv a0, s3
    jal free
    mv a0, s6
    jal free
    mv a0, s9
    jal free
    mv a0, s4
    jal free
    mv a0, s7
    jal free
    mv a0, s8
    jal free
    mv a0, s0
    jal free
    mv a0, s10
    jal free

done:
    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    lw s9, 40(sp)
    lw s10, 44(sp)
    lw s11, 48(sp)
    addi sp, sp, 52

    ret

malloc_error:
    li a1, 48
    jal exit2

incorrect_arg:
    li a1, 35
    jal exit2