my $ref38 = "/work6/PMFP/u00ccl01/reference_GRCh38/hs38DH.fa";
my $ref19 = "/work6/PMFP/u00ccl01/ref_hg19/genome.fa";
my $reference = $ref19;
my $sampleN  = "NV0017-01_S4";
my $sampleT  = "NV0017-03_S6";

my @sampleTN =($sampleN ,$sampleT);
my $path = "/work6/PMFP/u00ccl01/NV0017";

system ("~/bin/manta/bin/configManta.py --bam=$sampleN/$sampleN.mark.sort.bam --tumorBam=$sampleT/$sampleT.mark.sort.bam --referenceFasta=$reference");
chdir ("$path/$sample/MantaWorkflow/");
system ("bsub -q petsai128G -o std -e err -J $sample.manta \"./runWorkflow.py --mode=local --jobs=40\"");
