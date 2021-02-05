#!/pkg/biology/Perl/Perl_v5.28.0/bin/perl

#Modules to use
use PBS::Client

my $rtg = "~/bin/rtg";
my $path = "/project/GP1/jimmy200340/181109_A00361_0027_BH5WVMDSXX/Unalign/WES";
chdir $path;
my @sample = `ls | cut -d "_" -f1,2 | uniq`;

my $pbs = PBS::Client->new();


foreach $sample(@sample)
{
	chomp $sample;
	#RTGtool
	my $sample_rtg = PBS::Client::Job->new
	(
		queue => 'ngs192G',
		name => "$sample.rtg",
		project => "MST107119",
		group => "MST107119",
		ofile => "$sample.rtg.std",
		efile => "$sample.rtg.err",
		cmd => "cd $path/$sample/StrelkaGermlineWorkflow/results/variants/ ; ~/bin/rtg vcfstats variants.vcf.gz > vcfstats.txt",
	);
	
	#Send Jobs into Queue
	$pbs->qsub($sample_rtg);

}