#!/usr/bin/perl

use strict;
use warnings;

##Bam files and VCF files from dragen, VCF header file and 3x scripts are needed for this pipeline to be contained all within one folder of currently x28 bam and x28 vcf files.

##Tabix and zip files for vcf-merge tool and remove a line that causes problems ##Dragen
my $f;
system("for f in *.vcf; do dos2unix \$f; grep -v '##DRAGEN' \$f > \$f.2; bgzip \$f.2; tabix -p vcf \$f.2.gz; done") == 0  or die "bgzip and tabix failed: $?";

##Get the zipped files in the folder
system("ls -d -1 \$PWD/*.vcf.2.gz > vcf.txt") == 0  or die "vcf list file failed: $?";

#This is used to generate your list of reads
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

#Check how many files you have
 print "$ii x vcf files\n";

##################################################################
###Merge VCF
##################################################################

system("vcf-merge $data[0] $data[1] $data[2] $data[3] $data[4] $data[5] $data[6] $data[7] $data[8] $data[9] $data[10] $data[11] $data[12] $data[13] $data[14] $data[15] $data[16] $data[17] $data[18] $data[19] $data[20] $data[21] $data[22] $data[23] $data[24] $data[25] $data[26] $data[27] > merged.vcf\n") == 0  or die "system vcf merge job failed: $?";

##################################################################
###remove SNPs with less than 24 1 read coverage vs 28 samples
##################################################################

system("cut -f1-2 merged.vcf >bedoutfile.txt\n") == 0  or die "system bed file creation step1 job failed: $?";
system("grep -v '#' bedoutfile.txt > bedoutfile2.txt\n") == 0  or die "system bed file creation step2 job failed: $?";
system("cut -f2 bedoutfile2.txt >bedoutfile3.txt\n") == 0  or die "system bed file creation step3 failed: $?";
system("paste bedoutfile2.txt bedoutfile3.txt > outbed.bed\n") == 0  or die "system bed file creation step4 job failed: $?";
system("awk '{\$3+=1}1' outbed.bed > outbed2.bed\n") == 0  or die "system bed file creation step5 job failed: $?";
system("sed -r 's/\\s+/\t/g' outbed2.bed > outbed3.bed\n") == 0  or die "system bed file creation step6 failed: $?";

   
##Get coverage for each snp position using bedtools for each vcf and cut the coverage column from each bam file
system("for f in *.bam; do bedtools coverage -abam \$f -b outbed3.bed | cut -f4 - > \$f.2.bed ; done") == 0  or die "bedtools coverage1: $?";

##redundant
#system("for f in *.bam.bed; do cut -f4 \$f > \$f.2.bed ; done") == 0  or die "bedtools coverage2: $?";

##Get all coverage column files for vcfs from previous step
my @bed;
system("ls -d -1 \$PWD/*.bam.bed.2.bed > bed.txt") == 0  or die "bed list file failed: $?";
open (READS, "<bed.txt");
while (<READS>) {
	 chomp;
	 push (@bed, $_);
 }
close READS;
 
##paste the coverage files into one file
system("paste outbed3.bed $bed[0] $bed[1] $bed[2] $bed[3] $bed[4] $bed[5] $bed[6] $bed[7] $bed[8] $bed[9] $bed[10] $bed[11] $bed[12] $bed[13] $bed[14] $bed[15] $bed[16] $bed[17] $bed[18] $bed[19] $bed[20] $bed[21] $bed[22] $bed[23] $bed[24] $bed[25] $bed[26] $bed[27] > multibed2.bed\n") == 0  or die "multibed list file failed: $?";
 
##A script to remove positions which don't have 24 samples of coverage of 1 read or more
system("./filter_coverage.pl > above23_positions.txt\n") == 0  or die "filter coverage script failed: $?";

##A loop to filter each VCF for good positions and filter the non-24 sample positions out
my $vcffilename2;
for (my $i=0; $i<$ii; $i++) {
$vcffilename2=$data[$i];

#remove .vcf from sample name
my @values = split('\.', $data[$i]);
#Get last split for sample ID name
my $name = ( split '/', $values[0] )[ -1 ];
 
system("awk -F'\t' 'NR==FNR{c[\$1\$2]++;next};c[\$1\$2] > 0' above23_positions.txt $name.vcf > $name.24sam.vcf\n") == 0  or die "system vcf AWK filter job3 failed: $?"; 
 }


###############################################################
# filter het / hom criteria
###############################################################
$ii=28;
my $vcffilename3;
for (my $i=0; $i<$ii; $i++) {
$vcffilename3=$data[$i];

#remove .vcf from sample name
my @values = split('\.', $data[$i]);
#Get last split for sample ID name
my $name = ( split '/', $values[0] )[ -1 ];

system("./filter_hethom.pl $name.24sam.vcf > $name.24sam.hethom.vcf\n") == 0  or die "system filter het hom job failed: $?"; 
 }
 
 
###############################################################
# individual snps for each sample
###############################################################
 
##tabix and bgzip vcf files and add missing headers
system("for f in *.24sam.hethom.vcf; do dos2unix \$f; cat header2.txt \$f > \$f.2; bgzip \$f.2; tabix -p vcf \$f.2.gz; done") == 0  or die "bgzip and tabix failed: $?";

##get list of filtered vcf files to use next.
system("ls -d -1 \$PWD/*.24sam.hethom.vcf.2.gz > vcf2.txt") == 0  or die "vcf list2 file failed: $?";
#This is used to generate your list of reads
my $iii=0;
my @data2;

#Put list of read files that are located in the vcf2.txt file in this directory into array and record size of array
open (READS, "<vcf2.txt");
while (<READS>) {
	 chomp;
	 push (@data2, $_);
	 $iii++;
}
close READS;


my @array = (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27);      
for (my $i=0; $i<$iii; $i++) {

#put each array element as string. These values will change as array elements are moved cyclically. 
my $string0=$array[0];
my $string1=$array[1];
my $string2=$array[2];
my $string3=$array[3];
my $string4=$array[4];
my $string5=$array[5];
my $string6=$array[6];
my $string7=$array[7];
my $string8=$array[8];
my $string9=$array[9];
my $string10=$array[10];
my $string11=$array[11];
my $string12=$array[12];
my $string13=$array[13];
my $string14=$array[14];
my $string15=$array[15];
my $string16=$array[16];
my $string17=$array[17];
my $string18=$array[18];
my $string19=$array[19];
my $string20=$array[20];
my $string21=$array[21];
my $string22=$array[22];
my $string23=$array[23];
my $string24=$array[24];
my $string25=$array[25];
my $string26=$array[26];
my $string27=$array[27];

##Command to get unique snps for each sample also including the cadenza controls to further remove background
 system("vcf-isec -f -c $data2[$string0] $data[$string1] $data[$string2] $data[$string3] $data[$string4] $data[$string5] $data[$string6] $data[$string7] $data[$string8] $data[$string9] $data[$string10] $data[$string11] $data[$string12] $data[$string13] $data[$string14] $data[$string14] $data[$string15] $data[$string16] $data[$string17] $data[$string18] $data[$string19] $data[$string20] $data[$string21] $data[$string22] $data[$string23] $data[$string24] $data[$string25] $data[$string26] $data[$string27] /home/data/wheat_ems_mutation/Dragen_cadenza_controls/Sample_1116_LIB10020_LDI8275.vcf.2.gz /home/data/wheat_ems_mutation/Dragen_cadenza_controls/Sample_1128_LIB10021_LDI8276.vcf.2.gz /home/data/wheat_ems_mutation/Dragen_cadenza_controls/Sample_1128_LIB10022_LDI8277.vcf.2.gz /home/data/wheat_ems_mutation/Dragen_cadenza_controls/Sample_1132_LIB10313_LDI8531.vcf.2.gz /home/data/wheat_ems_mutation/Dragen_cadenza_controls/Sample_1132_LIB10314_LDI8532.vcf.2.gz /home/data/wheat_ems_mutation/Dragen_cadenza_controls/Sample_1132_LIB10315_LDI8533.vcf.2.gz /home/data/wheat_ems_mutation/Dragen_cadenza_controls/Sample_1132_LIB10316_LDI8534.vcf.2.gz /home/data/wheat_ems_mutation/Dragen_cadenza_controls/Sample_1133_LIB10317_LDI8535.vcf.2.gz /home/data/wheat_ems_mutation/Dragen_cadenza_controls/Sample_1133_LIB10318_LDI8536.vcf.2.gz /home/data/wheat_ems_mutation/Dragen_cadenza_controls/Sample_1134_LIB10495_LDI8690.vcf.2.gz /home/data/wheat_ems_mutation/Dragen_cadenza_controls/Sample_1147_LIB10700_LDI8902.vcf.2.gz /home/data/wheat_ems_mutation/Dragen_cadenza_controls/Sample_1147_LIB10701_LDI8903.vcf.2.gz /home/data/wheat_ems_mutation/Dragen_cadenza_controls/Sample_1149_LIB10703_LDI8905.vcf.2.gz /home/data/wheat_ems_mutation/Dragen_cadenza_controls/Sample_1158_LIB11007_LDI9084.vcf.2.gz /home/data/wheat_ems_mutation/Dragen_cadenza_controls/Sample_1162_LIB11008_LDI9085.vcf.2.gz /home/data/wheat_ems_mutation/Dragen_cadenza_controls/Sample_1162_LIB11009_LDI9086.vcf.2.gz /home/data/wheat_ems_mutation/Dragen_cadenza_controls/Sample_1170_LIB11492_LDI9431.vcf.2.gz /home/data/wheat_ems_mutation/Dragen_cadenza_controls/Sample_1170_LIB11493_LDI9432.vcf.2.gz /home/data/wheat_ems_mutation/Dragen_cadenza_controls/Sample_1171_LIB11494_LDI9433.vcf.2.gz /home/data/wheat_ems_mutation/Dragen_cadenza_controls/Sample_1171_LIB11495_LDI9434.vcf.2.gz /home/data/wheat_ems_mutation/Dragen_cadenza_controls/Sample_1176_LIB11490_LDI9429.vcf.2.gz /home/data/wheat_ems_mutation/Dragen_cadenza_controls/Sample_1176_LIB11491_LDI9430.vcf.2.gz /home/data/wheat_ems_mutation/Dragen_cadenza_controls/Sample_1238_LIB10702_LDI8904.vcf.2.gz /home/data/wheat_ems_mutation/Dragen_cadenza_controls/Sample_1238_LIB10704_LDI8906.vcf.2.gz /home/data/wheat_ems_mutation/Dragen_cadenza_controls/Sample_1238_LIB10705_LDI8907.vcf.2.gz /home/data/wheat_ems_mutation/Dragen_cadenza_controls/Sample_1238_LIB10706_LDI8908.vcf.2.gz > $data[$string0].filtered.unique.vcf\n") == 0  or die "system vcf isec filter job failed: $?"; 

 #cycle the array elements
 push(@array, splice(@array, 0, 1));
}

##remove unwanted files
system("rm *.txt \n") == 0  or die "system remove file job failed: $?";
system("rm *.bed \n") == 0  or die "system remove file job failed: $?";
system("rm *.24sam.hethom.vc* \n") == 0  or die "system remove file job failed: $?";


