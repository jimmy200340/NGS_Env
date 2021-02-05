use PBS::Client;

#create PBS client object
my $pbs = PBS::Client->new();
my $qualimap = "~/bin/qualimap";
my $path = "/work2/jimmy200340/NIST/30X_NIST/fastp";
my $target_region = "/work2/jimmy200340/CRE_V2_hg38_Regions_new.bed";
my $core = "40";
my $region = "-gff $target_region";

#sample names
chdir $path;
my @sample = `ls | cut -d "_" -f1,2 | uniq`;

#create PBS client object
my $pbs = PBS::Client->new();


foreach $sample(@sample)
{
	chomp $sample;

	#bamqc
	my $bamqc = PBS::Client::Job->new
	(
		queue => 'ngs192G',
		name => "$sample.bamqc",
		project => "MST107119",
		group => "MST107119",
		ofile => "$sample.bamqc.std",
		efile => "$sample.bamqc.err",
		cmd => "cd $path/$sample ; mkdir bamqc ; $qualimap bamqc -bam $sample.mark.sort.bam -nt $core -c -outdir $path/$sample/bamqc --java-mem-size=180G",
	);

	#Send Jobs into Queue
	$pbs->qsub($bamqc);
}