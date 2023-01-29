.import ../../src/read_matrix.s
.import ../../src/utils.s

.data
file_path: .asciiz "inputs/test_read_matrix/test_input.bin"

.text
main:
    # Read matrix into memory
    la s0 file_path
    mv a0 s0
    jal ra read_matrix

    # Print out elements of matrix
    jal ra print_int_array


    # Terminate the program
    jal exit