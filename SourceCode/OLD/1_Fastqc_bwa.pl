use LSF;

#my $reference = "/work6/PMFP/u00ccl01/reference_GRCh38/hs38DH.fa";
my $reference = "/work6/PMFP/u00ccl01/ref_hg19/genome.fa";
my $path = "/work6/PMFP/u00ccl01/Special_D14768";
my @sample = ("D14768");
my $RG1 = '"@RG\tID:BRCA\tSM:';
my $RG2 = '\tPL:illumina"';


#BWA-mem
foreach $sample(@sample)
{
	system ("mkdir $sample");
	$readgroup = $RG1.$sample.$RG2;
	$sample = LSF::Job->submit (-q => 128G, -o => "bwa.std", -e => "bwa.err", -J => "$sample.bwa", "bwa mem -M -R $readgroup -t 40 -K 10000000 $reference $path/$sample\_R1.fastq.gz $path/$sample\_R2.fastq.gz | samblaster -M -e | samtools view -bS -o $sample.bam -");
    chdir ("$path");
}
