#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "lfsr.h"
#include "bit_ops.h"

void lfsr_calculate(uint16_t *reg) {
    /* YOUR CODE HERE */
    int zero = get_bit(*reg, 0);
    int two = get_bit(*reg, 2);
    int three = get_bit(*reg, 3);
    int five = get_bit(*reg, 5);
    int target = zero ^ two ^ three ^ five;
    *reg = *reg >> 1;
    set_bit(reg, 15, target);
}

