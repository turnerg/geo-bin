#!/usr/bin/perl
my @nums =  ();
my $min, $max ;

while (<>) {
  chomp();
  #print "$_\n";
  $sum += $_;
  push @nums, $_ ;
}

$min=$nums[0];
$max=$nums[0];
my $npts=$#nums + 1;
for (my $i=1; $i < $npts ; $i++ ) {
  $min = $nums[$i] if $nums[$i] < $min;
  $max = $nums[$i] if $nums[$i] > $max;
}

print "$min   $max\n";

exit;

