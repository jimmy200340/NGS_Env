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

#reference version
my $reference = "";
my $ref38 = "/project/GP1/jimmy200340/Reference/ref_GRCh38/genome.fa";
my $ref38_all = "/project/GP1/jimmy200340/Reference/ref_GRCh38.1/genome.fa";
my $ref19 = "/project/GP1/jimmy200340/Reference/ref_hg19/genome.fa";

my $reference = $ref38;

my $path = "/project/GP1/jimmy200340/181109_A00361_0027_BH5WVMDSXX/Unalign/WES";
my $target_region = "/project/GP1/jimmy200340/181109_A00361_0027_BH5WVMDSXX/Unalign/CRE_V2_hg38_Regions_new.txt";
#my $out_path="/project/GP1/u00ccl01/$project";
#chdir $path;
chdir $path;
my @sample = `ls | cut -d "_" -f1,2 | uniq`;

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
        queue => 'ngs192G',
        name => "$sample.stats",
        project => "MST107119",
        group => "MST107119",
        ofile => "$sample.stats.std",
        efile => "$sample.stats.err",
        cmd => "cd $path/$sample ; $samtools stats -@ $core -t $target_region -c 1,600,50 -r $reference $sample.mark.sort.bam > $path/$sample/$sample.mark.sort.bam.stats",
    );


   # plot-bamstats
   my $sample_plot = PBS::Client::Job->new
   (
        queue => 'ngs192G',
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
        queue => 'ngs192G',
        name => "$sample.cov",
        project => "MST107119",
        group => "MST107119",
        ofile => "$sample.cov.std",
        efile => "$sample.cov.err",
        cmd => "cd $path/$sample ; grep ^COV $sample.mark.sort.bam.stats | cut -f 2- > $path/$sample/$sample.cov",
    );

   #count depth over coverage
        #print $sample."\n";

   #Set Job Dependency
   $sample_stats->next({ok => $sample_plot});
   $sample_plot->next({ok => $sample_cov});
  
  
   #Send Jobs into Queue
   $pbs->qsub($sample_stats);
 }
