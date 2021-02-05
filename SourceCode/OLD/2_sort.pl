my $path = "/work6/PMFP/u00ccl01/Special_D14768";
my @sample = ("D14768");

foreach $sample(@sample)
{
    system ("bsub -q 128G -o sort.std -e sort.err -J $sample.sort \"samtools sort -@ 40 -o $sample.mark.sort.bam $sample.bam\"");
}
