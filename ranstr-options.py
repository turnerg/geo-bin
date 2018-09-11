#!/Users/turnerg/anaconda/bin/python

#!/usr/bin/python

import sys, getopt
import random as r

def generate_random_string(len_sep, no_of_blocks):
    random_string = ''
    random_str_seq = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    for i in range(0,len_sep*no_of_blocks):
        if i % len_sep == 0 and i != 0:
            random_string += '-'
        random_string += str(random_str_seq[r.randint(0, len(random_str_seq) - 1)])
    return random_string

def main(argv):
   blocks = '1'
   length = '10'
   try:
      opts, args = getopt.getopt(argv,"hb:l:",["blocks=","length="])
   except getopt.GetoptError:
      print 'ranstr.py -l <length of random string> -b <number of blocks>'
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print 'test.py -b <number of blocks> -l <length>'
         sys.exit()
      elif opt in ("-b", "--blocks"):
         blocks = arg
      elif opt in ("-l", "--length"):
         length = arg
   #print 'Length is :', length
   #print 'Number of blocks :', blocks
   
   print generate_random_string(int(length), int(blocks))


if __name__ == "__main__":
   main(sys.argv[1:])

