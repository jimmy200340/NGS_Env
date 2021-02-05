use LSF;
my $reference = "/work6/PMFP/u00ccl01/ref_hg19/genome.fa";
#my @sample = ("D14769_NV0003-02", "D14770_NV0003-03", "D14801_NV0003-11", "D14802_NV0003-12", "D14793_NV0003-14", "D14794_NV0003-15", "D14816_NV0003-08", "D14815_NV0003-07", "D14817_NV0003-09", "D14424_NV0003-10", "D14768_NV0003-01", "D14807_NV0003-05", "D14806_NV0003-04", "D14819_NV0003-13", "D14808_NV0003-06");
my $path = "/home/u00ccl01/work6_u00ccl01/Special_D14768";
my @sample = ("D14768");



foreach $sample(@sample)
{
   chdir ("$path/$sample/");
   my $dir_out = $sample."_outfile";
   #system ("mkdir $dir_out");
  # $readgroup = $RG1.$sample.$RG2;
   $sample_JID =  LSF::Job->submit (-q => "48G", -o => "stats.std",   -e => "stats.err",     -J => "$sample.stats",    "samtools stats -@ 20 -c 1,60,1  -r $reference  $sample.mark.sort.bam > $sample.mark.sort.bam.stats");
   $sample_JID1 = LSF::Job->submit (-w => "done($sample_JID)", -q => "48G", -o => "plot.std",    -e => "plot.err",  -J => "$sample.plot",     "plot-bamstats -p $dir_out $sample.mark.sort.bam.stats" );
   $sample_JID2 = LSF::Job->submit (-w => "done($sample_JID)",  -q => "48G", -o => "cov.std",     -e => "cov.err",  -J => "$sample.cov",      "grep ^COV $sample.mark.sort.bam.stats | cut -f 2- > $sample.cov" );
   $sample_JID3 = LSF::Job->submit (-w => "done($sample_JID2)",  -q => "48G", -o => "dep_cov.std",     -e => "dep_cov.err",  -J => "$sample.dep_cov", "perl $path/dep_cov.pl $sample.cov > $sample.dep_cov" );
# chdir ("$path/$sample/StrelkaGermlineWorkflow/results/variants/");
#   $sample_J =    LSF::Job->submit (-q => nhri48G, -o => "vcfstats.std", -e => "vcfstats.err", -J => "$sample.vcfstats", "rtg vcfstats variants.vcf.gz > $path/$sample/$sample.vcfstats");
}

