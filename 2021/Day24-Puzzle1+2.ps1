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
#   z = 16+w1
#   z = 16+w1, 3+w2
#   z = 16+w1, 3+w2, 2+w3
#   z = 16+w1, 3+w2, 2+w3, 7+w4
#   z = 16+w1, 3+w2, 2+w3, (POP FROM STACK)
#   z = 16+w1, 3+w2, 2+w3, 6+w6
#   z = 16+w1, 3+w2, 2+w3, (POP FROM STACK)
#   z = 16+w1, 3+w2, 2+w3, 11+w8
#   z = 16+w1, 3+w2, 2+w3, (POP FROM STACK)
#   z = 16+w1, 3+w2, (POP FROM STACK)
#   z = 16+w1, 3+w2, 11+w11
#   z = 16+w1, 3+w2, (POP FROM STACK)
#   z = 16+w1, (POP FROM STACK)
#   z = (POP FROM STACK)
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
