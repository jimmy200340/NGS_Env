use PBS::Client;

#create PBS client object
my $pbs = PBS::Client->new();
my $bcl2fastq = "~/bin/bcl2fastq";
my $fastqc = "~/bin/fastqc";
my $path = "/work2/jimmy200340/190311_A00321_0024_BH7JLTDSXX";
my $core = "40";


#demultiplex
my $demultiplex = PBS::Client::Job->new
(
	queue => 'nhri192G',
	name => "demultiplex",
	project => "MST107119",
	group => "MST107119",
	ofile => "demultiplex.std",
	efile => "demultiplex.err",
	cmd => "cd $path ; $bcl2fastq -r 20 -p 40 -w 20 --ignore-missing-bcls --ignore-missing-filter --ignore-missing-positions --ignore-missing-controls --auto-set-to-zero-barcode-mismatches --find-adapters-with-sliding-window --adapter-stringency 0.9 --mask-short-adapter-reads 35 --minimum-trimmed-read-length 35 --use-bases-mask 1:y*,i*,n*,y* ; mkdir Unalign_SI ; cd Unalign_SI/ ; mv ../Data/Intensities/BaseCalls/*.gz ./ ; mv ../Data/Intensities/BaseCalls/*/*.gz ./",
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
	cmd => "cd $path/Unalign_SI ; mkdir _fastqc ; $fastqc --outdir $path/Unalign_SI/_fastqc --casava --extract --format fastq --threads $core *.gz",
);


#Set Job Dependency
$demultiplex->next({ok => $fastQC});

#Send Jobs into Queue
$pbs->qsub($demultiplex);
