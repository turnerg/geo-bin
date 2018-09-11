#!/Users/turnerg/anaconda/bin/python

#!/usr/bin/python

import sys, getopt

def main(argv):
   blocks = '1'
   length = '10'
   try:
      opts, args = getopt.getopt(argv,"hb:l:",["blocks=","length="])
   except getopt.GetoptError:
      print 'test.py -i <inputfile> -o <outputfile>'
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print 'test.py -b <number of blocks> -l <length>'
         sys.exit()
      elif opt in ("-b", "--blocks"):
         blocks = arg
      elif opt in ("-l", "--length"):
         length = arg
   print 'Length is :', length
   print 'Number of blocks :', blocks

if __name__ == "__main__":
   main(sys.argv[1:])

