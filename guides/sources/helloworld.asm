.globl __start

.data
msg1:
  .string "Hello World!"
  .byte 0

.text

__start:
    la a0, msg1
    li a7, 4
    ecall

    j Shutdown

Shutdown:
  li a7, 10
  ecall
