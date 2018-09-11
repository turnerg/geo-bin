#!/Users/turnerg/anaconda/bin/python

#!/usr/bin/python

import sys, getopt
import random as r

#print 'Number of arguments:', len(sys.argv), 'arguments.'
#print 'Argument List:', str(sys.argv)

#print 'Arg 0:', str(sys.argv[0])

length = 25
blocks = 1

if len(sys.argv) >= 2:
	#print 'Arg 1:', str(sys.argv[1])
	length = int(sys.argv[1])

if len(sys.argv) == 3:
	#print 'Arg 2:', str(sys.argv[2])
	blocks = int(sys.argv[2])

#print 'length:', length
#print 'blocks:', blocks

random_string = ''
random_str_seq = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
for i in range(0,length*blocks):
    if i % length == 0 and i != 0:
        random_string += '-'
    random_string += str(random_str_seq[r.randint(0, len(random_str_seq) - 1)])
print random_string

