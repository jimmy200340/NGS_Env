#!/pkg/biology/Perl/Perl_v5.28.0/bin/perl

#Modules to use
use PBS::Client

#Project id
#107119

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
my $ref19 = "/pkg/biology/reference/Homo_sapiens/UCSC/hg19/Sequence/BWAIndex/genome.fa";

#Genome codename
my $genome = "";
	#hg19
	my $UCSC_Ref_19 = "hg19";
	my $ENSEMBL_19 = "GRCh37.75";
	my $UCSC_Known_19 = "hg19kg";
	my $NCBI_Ref_19 = "GRCh37.p13.RefSeq";
	
	#hg38
	my $UCSC_Ref_38 = "hg38";
	my $ENSEMBL_38 = "GRCh38.86";
	my $UCSC_Known_38 = "hg38kg";
	my $NCBI_Ref_38 = "GRCh38.p7.RefSeq";

#Run path
my $path = "/work2/jimmy200340/190311_A00321_0024_BH7JLTDSXX/Unalign_SI/WES004";
my $target_region = "/work2/jimmy200340/CRE_V2_hg38_Regions_new.txt";

#clineff path
my $clineff = "/pkg/biology/ClinEff/ClinEff_v1.0h/";
#clineff license
my $efflicense = "/work2/jimmy200340/license/";

#sample names
chdir $path;
my @sample = `ls | cut -d "_" -f1,2 | uniq`;

#readgroup
my $RG1 = '"@RG\tID:NovaSeq\tSM:';
my $RG2 = '\tPL:illumina"';

#CPU core
my $core = "40";

#create stat file
open (DATA,">stats.txt")|| die "cannot open file";
print DATA "\tBND\tINV\tDEL\tINS\tDUP\tLOSS\tGAIN\n";

#reference to use
my $reference = $ref38;

#genome to use
my $genome = $NCBI_Ref_38;

#create PBS client object
my $pbs = PBS::Client->new();

foreach $sample(@sample)
{
	chomp $sample;
	system ("mkdir $sample");
	$readgroup = $RG1.$sample.$RG2;
		
	#BWA & Mark Duplicates
	my $sample_bwa = PBS::Client::Job->new
	(
		queue => 'nhri192G',
		name => "$sample.bwa",
		project => "MST107119",
		group => "MST107119",
		ofile => "$sample.bwa.std",
		efile => "$sample.bwa.err",
		cmd => "cd $path ; ~/bin/bwa mem -M -R $readgroup -t $core -K 10000000 $reference $path/$sample\_L001_R1_001.fastq.gz $path/$sample\_L001_R2_001.fastq.gz | $samblaster -M -e | $samtools view -bS -o $path/$sample.bam -",
	);
	
	#sort
	my $sample_sort = PBS::Client::Job->new
	(
		queue => 'nhri192G',
		name => "$sample.sort",
		project => "MST107119",
		group => "MST107119",
		ofile => "$sample.sort.std",
		efile => "$sample.sort.err",
		cmd => "cd $path ; $samtools sort -@ $core -o $path/$sample.mark.sort.bam $path/$sample.bam",
	);
	
	#index
	my $sample_index = PBS::Client::Job->new
	(
		queue => 'nhri192G',
		name => "$sample.index",
		project => "MST107119",
		group => "MST107119",
		ofile => "$sample.index.std",
		efile => "$sample.index.err",
		cmd => "cd $path ; $samtools index -@ $core $path/$sample.mark.sort.bam",
	);
	
	#MoveBAM
	my $sample_move = PBS::Client::Job->new
	(
		queue => 'nhri192G',
		name => "$sample.move",
		project => "MST107119",
		group => "MST107119",
		ofile => "$sample.move.std",
		efile => "$sample.move.err",
		cmd => "cd $path ; mv $path/$sample.mark.sort.bam $path/$sample ; mv $path/$sample.mark.sort.bam.bai $path/$sample ; rm $path/$sample.bam",
	);
	
	
	#Strelka_Germline_pre
	my $sample_prestrelka = PBS::Client::Job->new
	(
		queue => 'nhri192G',
		name => "$sample.prestrelka",
		project => "MST107119",
		group => "MST107119",
		ofile => "$sample.prestrelka.std",
		efile => "$sample.prestrelka.err",
		cmd => "cd $path/$sample ; ~/bin/Strelka2/bin/configureStrelkaGermlineWorkflow.py --bam=$sample.mark.sort.bam --referenceFasta=$reference",
	);
	
	#Strelka_Germline
	my $sample_strelka = PBS::Client::Job->new
	(
		queue => 'nhri192G',
		name => "$sample.strelka",
		project => "MST107119",
		group => "MST107119",
		ofile => "$sample.strelka.std",
		efile => "$sample.strelka.err",
		cmd => "cd $path/$sample/StrelkaGermlineWorkflow/ ; ./runWorkflow.py --mode=local --jobs=$core",
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
	
	
	#MoveLOG
	my $sample_mvlog = PBS::Client::Job->new
	(
		queue => 'nhri192G',
		name => "$sample.mvlog",
		project => "MST107119",
		group => "MST107119",
		cmd => "cd $path ; mv $sample*.std $path/$sample ; mv $sample*.err $path/$sample",
	);

   # samtools stats
   my $sample_stats = PBS::Client::Job->new
   (
        queue => 'nhri192G',
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
        cmd => "cd $path/$sample ; grep ^COV $sample.mark.sort.bam.stats | cut -f 2- | dep_cov_wes_hg38.pl > $path/$sample/$sample.cov",
    );
	
	#Set Job Dependency
	$sample_bwa->next({ok => $sample_sort});
	$sample_sort->next({ok => $sample_index});
	$sample_index->next({ok => $sample_move});
	$sample_move->next({ok => $sample_prestrelka});
	$sample_prestrelka->next({ok => $sample_strelka});
	$sample_strelka->next({ok => $sample_rtg});
	$sample_rtg->next({ok => $sample_stats});
	$sample_stats->next({ok => $sample_plot});
	$sample_plot->next({ok => $sample_cov});
	$sample_cov->next({ok => $sample_mvlog});
	
	
	
	#Send Jobs into Queue
	$pbs->qsub($sample_bwa);
}