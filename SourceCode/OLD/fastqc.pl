use PBS::Client;

#create PBS client object
my $pbs = PBS::Client->new();
my $fastqc = "~/bin/fastqc";
my $path = "/work2/u00ccl01/181204_A00322_0025_AHG3FMDMXX";
my $core = "40";

#fastQC
my $fastQC = PBS::Client::Job->new
(
	queue => 'ngs192G',
	name => "fastQC",
	project => "MST107119",
	group => "MST107119",
	ofile => "fastqc.std",
	efile => "fastqc.err",
	cmd => "cd $path/Unalign ; mkdir fastqc_reports ; $fastqc --outdir $path/Unalign/fastqc_reports --casava --extract --format fastq --threads $core *.gz",
);

#Send Jobs into Queue
$pbs->qsub($fastQC);
