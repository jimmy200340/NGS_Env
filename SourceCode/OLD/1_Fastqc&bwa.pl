my $reference = "/work6/PMFP/u00ccl01/reference_GRCh38/hs38DH.fa";
my $path = "/work6/PMFP/u00ccl01/old_5";
my @sample = ("5422_S1_L001","5422_S1_L002","SCID_002_S5_L001","SCID_002_S5_L002");
#my @sample_ex = @sample;
my $RG1 = '"@RG\tID:miseq\tSM:';
my $RG2 = '\tPL:illumina"';

system ("mkdir fastqc_reports");

#FastQC
foreach $sample(@sample)
{
	system ("bsub -q 512G-48 -o std -e err -J @sample.qc \"fastqc --outdir $path\fastqc_reports --casava --extract --format fastq --threads 40 *.gz\"");
}

#BWA-mem
foreach $sample(@sample)
{
	system ("mkdir $sample");
	$readgroup = $RG1.$sample.$RG2;
	system ("bsub -q 128G -o std -e err -J @sample.bwa \"bwa mem -M -R $readgroup -t 40 -K 10000000 $reference $path/$sample\_R1.fastq.gz $path/$sample\_R2.fastq.gz | samblaster -M -e | samtools view -bS -o $sample.bam -\"");
}