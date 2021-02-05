my $path = "/project/GP1/jimmy200340/181009_A00360_0022_AH5GJVDSXX/Unalign/NV0038";
chdir $path;
my @sample = `ls | cut -d "_" -f1,2 | uniq`;


foreach $sample(@sample)
{
	chomp $sample;
	system ("cat $sample\_L001_R1_001.fastq.gz $sample\_L002_R1_001.fastq.gz $sample\_L003_R1_001.fastq.gz $sample\_L004_R1_001.fastq.gz > $sample\_R1_001.fastq.gz &");
	system ("cat $sample\_L001_R2_001.fastq.gz $sample\_L002_R2_001.fastq.gz $sample\_L003_R2_001.fastq.gz $sample\_L004_R2_001.fastq.gz > $sample\_R2_001.fastq.gz &");
}