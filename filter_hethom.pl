#!/usr/bin/perl

use strict;
use warnings;

my ($file1) = @ARGV;

#Put list of read files that are located in the Reads.txt file in this directory into array and record size of array
open (READS, "<$file1");
while (<READS>) {
	chomp;


my @values = split('\t', $_);
my @data = split(':', $values[9]);
my @AD = split(',', $data[1]);


	if ($data[0]=~/0\/1/){
	
	if (($AD[1]==0) && ($AD[0]==0)){
	}else{
	
	my $perc=(($AD[1]/($AD[1]+$AD[0]))*100);
	if (($AD[1] >4) && ($perc>19.99)){
	print $_ . "\n";
	}
	}
	
	
	}elsif (($data[0]=~/1\/1/) && ($AD[1] >2)){
	print $_ . "\n";
	}

	
	}

	
	








