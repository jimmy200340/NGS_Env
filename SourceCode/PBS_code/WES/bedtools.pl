use PBS::Client;

#create PBS client object
my $pbs = PBS::Client->new();
my $bedtools = "~/bin/bedtools";
my $path = "/work2/jimmy200340/181109_A00361_0027_BH5WVMDSXX/Unalign/WES";
my $target_region = "/work2/jimmy200340/CRE_V2_hg38_Regions.bed";
my $core = "40";

#sample names
chdir $path;
my @sample = `ls | cut -d "_" -f1,2 | uniq`;

#create PBS client object
my $pbs = PBS::Client->new();


foreach $sample(@sample)
{
	chomp $sample;

	#bedtools
	my $bedtools = PBS::Client::Job->new
	(
		queue => 'ngs384G',
		name => "$sample.bedtools",
		project => "MST107119",
		group => "MST107119",
		ofile => "$sample.bedtools.std",
		efile => "$sample.bedtools.err",
		cmd => "cd $path/$sample ; $bedtools coverage -hist -b $sample.mark.sort.bam -a $target_region | grep ^all > $path/$sample/$sample.hist.txt",
	);

	#Send Jobs into Queue
	$pbs->qsub($bedtools);
}