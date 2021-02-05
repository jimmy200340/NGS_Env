my $reference = "/work6/PMFP/u00ccl01/reference_GRCh38/hs38DH.fa";
my @sample=("11657_S3","11666_S4","5422_S1","5907_S2","SCID_002_S5");
my $path = "/work6/PMFP/u00ccl01/old_5";


foreach $sample(@sample)
{
chdir $sample;
system ("~/bin/Strelka2/bin/configureStrelkaGermlineWorkflow.py --bam=$sample.mark.sort.bam --referenceFasta=$reference");
chdir ("$path/$sample/StrelkaGermlineWorkflow/");
system ("bsub -q 128G -o std -e err -J $sample.strelka \"./runWorkflow.py --mode=local --jobs=40\"");
chdir $path;
}