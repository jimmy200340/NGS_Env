use PBS::Client;

#create PBS client object
my $pbs = PBS::Client->new();
my $bcl2fastq = "~/bin/bcl2fastq";
my $fastqc = "~/bin/fastqc";
my $run = "190412_A00322_0034_BHC2YWDSXX";
my $path = "/work2/jimmy200340/".$run;
my $core = "40";

#--tiles s_1
#host => "cn0670",


#demultiplex
my $demultiplex = PBS::Client::Job->new
(
	queue => 'nhri192G',
	name => "demultiplex",
	project => "MST107119",
	group => "MST107119",
	ofile => "demultiplex.std",
	efile => "demultiplex.err",
	cmd => "cd $path ; $bcl2fastq -r 20 -p 40 -w 20 --ignore-missing-bcls --ignore-missing-filter --ignore-missing-positions --ignore-missing-controls --auto-set-to-zero-barcode-mismatches --find-adapters-with-sliding-window --adapter-stringency 0.9 --mask-short-adapter-reads 35 --minimum-trimmed-read-length 35 --tiles s_3,s_4; mkdir Unalign ; cd Unalign/ ; mv ../Data/Intensities/BaseCalls/*.gz ./ ; mv ../Data/Intensities/BaseCalls/*/*.gz ./",
);

#fastQC
my $fastQC = PBS::Client::Job->new
(
	queue => 'nhri192G',
	name => "fastQC",
	project => "MST107119",
	group => "MST107119",
	ofile => "fastqc.std",
	efile => "fastqc.err",
	cmd => "cd $path/Unalign ; mkdir _fastqc ; $fastqc --outdir $path/Unalign/_fastqc --casava --extract --format fastq --threads $core *.gz",
);



#Set Job Dependency
$demultiplex->next({ok => $fastQC});

#Send Jobs into Queue
$pbs->qsub($demultiplex);
