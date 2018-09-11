#!/Users/turnerg/anaconda/bin/python

#!/usr/bin/python

import sys

print 'Number of arguments:', len(sys.argv), 'arguments.'
print 'Argument List:', str(sys.argv)

print 'Arg 0:', str(sys.argv[0])
print 'Arg 1:', str(sys.argv[1])

if len(sys.argv) >= 2:
	#print 'Arg 1:', str(sys.argv[1])
	length = int(sys.argv[1])

if len(sys.argv) == 3:
	#print 'Arg 2:', str(sys.argv[2])
	blocks = int(sys.argv[2])

