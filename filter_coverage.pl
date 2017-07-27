#!/usr/bin/perl

use strict;
use warnings;





my $ii=0;


#Put list of read files that are located in the Reads.txt file in this directory into array and record size of array
open (READS, "<multibed2.bed");
while (<READS>) {
	chomp;
	$ii=0;
	my @data;
my @values = split('\t', $_);
push (@data, $values[3]);	
push (@data, $values[4]);	
push (@data, $values[5]);	
push (@data, $values[6]);	
push (@data, $values[7]);	
push (@data, $values[8]);	
push (@data, $values[9]);	
push (@data, $values[10]);	
push (@data, $values[11]);	
push (@data, $values[12]);	
push (@data, $values[13]);	
push (@data, $values[14]);	
push (@data, $values[15]);	
push (@data, $values[16]);	
push (@data, $values[17]);	
push (@data, $values[18]);	
push (@data, $values[19]);	
push (@data, $values[20]);	
push (@data, $values[21]);	
push (@data, $values[22]);	
push (@data, $values[23]);	
push (@data, $values[24]);	
push (@data, $values[25]);	
push (@data, $values[26]);	
push (@data, $values[27]);		
	foreach my $number (@data){
  if ($number >0){
  $ii=$ii+1;
  }
}
	if ($ii >23){
	print $_ . "\n";
	}
	
}







