my $reference = "/work6/PMFP/u00ccl01/ref_hg19/genome.fa";
my $path = "/work6/PMFP/u00ccl01/TVB084";
my @sample = ("TVB084N","TVB084T");


foreach $sample(@sample)
{
system ("mv $sample.mark.sort.bam $path/$sample");
system ("mv $sample.mark.sort.bam.bai $path/$sample");
system ("rm $sample.bam");
chdir $sample;
system ("~/bin/manta/bin/configManta.py --bam=$sample.mark.sort.bam --referenceFasta=$reference");
chdir ("$path/$sample/MantaWorkflow/");
system ("bsub -q 128G -o std -e err -J $sample.manta \"./runWorkflow.py --mode=local --jobs=40\"");
chdir $path;
}
