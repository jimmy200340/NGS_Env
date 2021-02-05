#!/pkg/biology/Perl/Perl_v5.28.0/bin/perl

#Modules to use
use PBS::Client

#Executable path
my $bwa = "~/bin/bwa";
my $samtools = "~/bin/samtools";
my $freec = "~/bin/freec";
my $samblaster = "~/bin/samblaster";
my $sambamba = "~/bin/sambamba";
my $bcl2fastq = "~/bin/bcl2fastq";
my $fastqc = "~/bin/fastqc";
my $plotbamstats = "~/bin/plot-bamstats";
my $rtg = "~/bin/rtg";

#reference version
my $reference = "";
my $ref38 = "/work2/jimmy200340/Reference/ref_GRCh38/genome.fa";
my $ref38_all = "/pkg/biology/reference/Homo_sapiens/NCBI/GRCh38/Sequence/WholeGenomeFasta/genome.fa";
my $ref19 = "/project/GP1/reference/Homo_sapiens/UCSC/hg19/Sequence/WholeGenomeFasta/genome.fa";

my $reference = $ref38;

my $path = "/work2/jimmy200340/NV0067";
#my $out_path="/work2/u00ccl01/$project";
#chdir $path;
chdir $path;
#my @sample = `ls | cut -d "_" -f1,2 | uniq`;
my @sample = ("NV0067-02","NV0067-03","NV0067-04","NV0067-05","NV0067-06","NV0067-07");

#CPU core
my $core = "40";


#create PBS client object
my $pbs = PBS::Client->new();


foreach $sample(@sample)
{
chomp $sample;

   # samtools stats
   my $sample_stats = PBS::Client::Job->new
   (
        queue => 'nhri192G',
        name => "$sample.stats",
        project => "MST107119",
        group => "MST107119",
        ofile => "$sample.stats.std",
        efile => "$sample.stats.err",
        cmd => "cd $path/$sample ; $samtools stats -@ $core -c 1,60,1 -r $reference $sample.mark.sort.bam > $path/$sample/$sample.mark.sort.bam.stats",
    );


   # plot-bamstats
   my $sample_plot = PBS::Client::Job->new
   (
        queue => 'nhri192G',
        name => "$sample.plot",
        project => "MST107119",
        group => "MST107119",
        ofile => "$sample.plot.std",
        efile => "$sample.plot.err",
        cmd => "cd $path/$sample ; $plotbamstats -p plot/ $sample.mark.sort.bam.stats",
    );


   # grep coverage
   my $sample_cov = PBS::Client::Job->new
   (
        queue => 'nhri192G',
        name => "$sample.cov",
        project => "MST107119",
        group => "MST107119",
        ofile => "$sample.cov.std",
        efile => "$sample.cov.err",
        cmd => "cd $path/$sample ; grep ^COV $sample.mark.sort.bam.stats | cut -f 2- | dep_cov_60x_hg38.pl > $path/$sample/$sample.cov",
    );

	#RTGtool
	my $sample_rtg = PBS::Client::Job->new
	(
		queue => 'nhri192G',
		name => "$sample.rtg",
		project => "MST107119",
		group => "MST107119",
		ofile => "$sample.rtg.std",
		efile => "$sample.rtg.err",
		cmd => "cd $path/$sample/StrelkaGermlineWorkflow/results/variants/ ; ~/bin/rtg vcfstats variants.vcf.gz > vcfstats.txt",
	);

   #count depth over coverage
        #print $sample."\n";

   #Set Job Dependency
   $sample_stats->next({ok => $sample_plot});
   $sample_plot->next({ok => $sample_cov});
   $sample_cov->next({ok => $sample_rtg});
  
  
   #Send Jobs into Queue
   $pbs->qsub($sample_stats);
 }
