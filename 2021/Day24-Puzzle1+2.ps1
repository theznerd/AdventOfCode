## Temporary Placeholder
## Need to generalize this for any puzzle input

## The basic way the serial num parser works
## is a stack on Z. Each instruction set
## (look at your input, you'll see a pattern)
## causes a number to be pushed or popped
## from the stack. We need to make sure the
## stack is empty by round 14... which gives
## us 7 pairs of push and pop. We just need
## to figure out when we're popping and
## determine the output for that step that
## pops the last element added to the stack.

## From my sample input
# z = stack (pop / push)
# instruction set
#  1  z = 16+w1
#  2  z = 16+w1, 3+w2
#  3  z = 16+w1, 3+w2, 2+w3
#  4  z = 16+w1, 3+w2, 2+w3, 7+w4
#  5  z = 16+w1, 3+w2, 2+w3, (5 is popping 4 from the stack)
#  6  z = 16+w1, 3+w2, 2+w3, 6+w6
#  7  z = 16+w1, 3+w2, 2+w3, (7 is popping 6 from the stack)
#  8  z = 16+w1, 3+w2, 2+w3, 11+w8
#  9  z = 16+w1, 3+w2, 2+w3, (9 is popping 8 from the stack)
#  10 z = 16+w1, 3+w2, (10 is popping 3 from the stack)
#  11 z = 16+w1, 3+w2, 11+w11
#  12 z = 16+w1, 3+w2, (12 is popping 11 from the stack)
#  13 z = 16+w1, (13 is popping 2 from the stack)
#  14 z = (14 is popping 1 from the stack)
##
##
# for a number to be valid (for the pops to work)
#  w5  == w4 - 3
#  w7  == w6 - 8
#  w9  == w8 + 7
#  w10 == w3 - 1
#  w12 == w11 + 8
#  w13 == w2 - 6
#  w14 == w1 + 4
#
# Maximum: 59996912981939
# Minimum: 17241911811915
