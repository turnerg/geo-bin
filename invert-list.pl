#!/usr/bin/perl

while (<>) {
  push @a, $_;
}

for ( reverse 0 .. $#a ) { 
  print "$a[$_]";
}
