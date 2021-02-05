use PBS::Client;

#create PBS client object
my $pbs = PBS::Client->new();
my $bcl2fastq = "~/bin/bcl2fastq";
my $fastqc = "~/bin/fastqc";
my $path = "/work2/jimmy200340/190730_A00361_0047_BHL75TDMXX";
my $core = "40";
my $fastp = "~/bin/fastp";
my $mem = "45gb";


   my $all_fastp = PBS::Client::Job->new
   (
        queue => 'nhri192G',
        name => "fastp",
        project => "MST108173",
        group => "MST108173",
		select => "1",
        mem => $mem,
        ncpus => $core,
        ofile => "fastp.std",
        efile => "fastp.err",
        cmd => "cd $path/Unalign; $fastp -w $core -i GA748-06_S38_L001_R1_001.fastq.gz -I GA748-06_S38_L001_R2_001.fastq.gz -h ./fastp.html",
   );
   $pbs->qsub($all_fastp);
