my $reference = "/work6/PMFP/u00ccl01/ref_hg19/genome.fa";
my $path = "/work6/PMFP/u00ccl01/Special_D14768";
my @sample = ("D14768");


foreach $sample(@sample)
{
	system ("bsub -q 128G -o $sample.idxstd -e $sample.idxerr -J $sample.index \"samtools index -@ 40 $sample.mark.sort.bam\"");
}