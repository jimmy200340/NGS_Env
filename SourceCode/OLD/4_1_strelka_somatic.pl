use LSF;

#reference version
my $reference = "";
my $ref38 = "/work6/PMFP/u00ccl01/reference_GRCh38/hs38DH.fa";
my $ref19 = "/work6/PMFP/u00ccl01/ref_hg19/genome.fa";
my $reference = $ref19;
my $sampleN  = "NV0017-01_S4";
my $sampleT  = "NV0017-03_S6";

my @sampleTN =($sampleN ,$sampleT);
my $path = "/work6/PMFP/u00ccl01/NV0017";


$sample_strelka_somatic_config = LSF::Job->submit ( -q => 'petsai128G', -J => "$sample.strelka_config", "~/bin/Strelka2/bin/configureStrelkaSomaticWorkflow.py --normalBam=./$sampleN/$sampleN.mark.sort.bam --tumorBam=./$sampleT/$sampleT.mark.sort.bam --indelCandidates=./MantaWorkflow/results/variants/candidateSmallIndels.vcf.gz --referenceFasta=$reference ; cd StrelkaSomaticWorkflow/");

$sample_strelka = LSF::Job->submit (-w => "done($sample_strelka_somatic_config)", -q => 'petsai128G', -o => "$sampleT.somatic.strelka.std", -e => "$sampleT.somatic.strelka.err", -J => "$sample.somatic.strelka", "cd $path/StrelkaSomaticWorkflow/ ; ./runWorkflow.py --mode=local --jobs=40");
