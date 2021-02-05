my $path = "/work2/jimmy200340/Dragen/TLCRC/somatic_ready";
chdir $path;
my %seen;
my @sample = `ls | cut -d "_" -f1,2 | uniq`;
my @source = ();
my @uniq = ();
my $T = "";
my $N = "";

foreach $sample(@sample)
{
	chomp $sample;
	chop $sample;
	push @source,$sample;
}

	@uniq = do {%seen ; grep { !$seen{$_}++ } @source };
	foreach $uniq(@uniq)
	{
		chomp $uniq;
		$N = "${uniq}N_germline";
		$T = "${uniq}T_germline";
		$Nbam = "${uniq}N.bam";
		$Tbam = "${uniq}T.bam";
		#print "$N\n";
		#print "$T\n";
		#print "$Nbam\n";
		#print "$Tbam\n";
		#chomp $N;
		#chomp $T;
		#chomp $Nbam;
		#chomp $Tbam;
		system ("mkdir /work2/jimmy200340/Dragen/TLCRC/$uniq\_somatic ; dragen -r /staging/human/reference/GRCh38/ --output-directory /work2/jimmy200340/Dragen/TLCRC/$uniq\_somatic/ --output-file-prefix $uniq -b /work2/jimmy200340/Dragen/TLCRC/somatic_ready/$N/$Nbam --tumor-bam-input /work2/jimmy200340/Dragen/TLCRC/somatic_ready/$T/$Tbam --enable-variant-caller true --enable-map-align false > /work2/jimmy200340/Dragen/TLCRC/$uniq\_somatic/screenlog 2>&1");
	}


#my @unique = do { my %seen; grep { !$seen{$_}++ } @words };
