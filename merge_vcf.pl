#!/usr/bin/perl

use strict;
use warnings;



##Get the vcf files in the folder
system("ls -d -1 \$PWD/*.vcf > vcf.txt") == 0  or die "vcf list file failed: $?";

#Put list of read files that are located in the Reads.txt file in this directory into array and record size of array
my $ii=0;
my @data;

#Put list of read files that are located in the Reads.txt file in this directory into array and record size of array
open (READS, "<vcf.txt");
while (<READS>) {
	chomp;
	 push (@data, $_);
	 $ii++;
	 
}

close READS;



for (my $i=0; $i <= 1202; $i++) {

open (READS, "<$data[$i]");
while (<READS>) {
	chomp;
  next if /^#/;

my @values = split('\t', $_);
my @columns = split(/_/,$data[$i]);

print $values[0] . "\t" . $values[1] . "\t" . $columns[5] . "\t" . $values[3] . "\t" . $values[4] . "\t" . $values[5] . "\t" . $values[6] . "\t" . $values[7] . "\t" . $values[8] . "\t" . $values[9] . "\n";


	
	}
		close READS;
		
	}
	

	
	

	
