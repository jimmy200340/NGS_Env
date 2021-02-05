#!/pkg/biology/Perl/Perl_v5.28.0/bin/perl

#Modules to use
#use PBS::Client

#Run path
my $path = "/project/GP1/jimmy200340/181109_A00361_0027_BH5WVMDSXX/Unalign/WES"; 

chdir $path;
my @sample = `ls | cut -d "_" -f1,2 | uniq`;
print @sample;


foreach $sample(@sample)
{
	chomp $sample;
   # grep coverage
        system ("cd $path/$sample ; grep ^COV $sample.mark.sort.bam.stats | cut -f 2- | dep_cov_wes_hg38.pl > $path/$sample/$sample.cov");
}