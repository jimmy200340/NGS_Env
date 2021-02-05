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

#reference version
my $reference = "";
my $ref38 = "/project/GP1/jimmy200340/Reference/ref_GRCh38/genome.fa";
my $ref38_all = "/project/GP1/jimmy200340/Reference/ref_GRCh38.1/genome.fa";
my $ref19 = "/project/GP1/jimmy200340/Reference/ref_hg19/genome.fa";

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
my $path = "/project/GP1/jimmy200340/181109_A00361_0027_BH5WVMDSXX/Unalign/2";

#clineff path
my $clineff = "/pkg/biology/ClinEff/ClinEff_v1.0h/";
#clineff license
my $efflicense = "/project/GP1/jimmy200340/license/";

#sample names
chdir $path;
my @sample = `ls | cut -d "_" -f1,2 | uniq`;


#readgroup
my $RG1 = '"@RG\tID:NovaSeq\tSM:';
my $RG2 = '\tPL:illumina"';

#stat variables
my $BND = "0";
my $INV = "0";
my $DEL = "0";
my $INS = "0";
my $DUP = "0";
my $loss = "0";
my $gain = "0";

#CPU core
my $core = "40";

#create stat file
open (DATA,">stats.txt")|| die "cannot open file";
print DATA "\tBND\tINV\tDEL\tINS\tDUP\tLOSS\tGAIN\n";

#reference to use
my $reference = $ref38;

#genome to use
my $genome = $NCBI_Ref_38;

#freec_conf
foreach $sample(@sample)
{
chomp $sample;
system ("mkdir $sample");
chdir $sample;
mkdir freec;
chdir ("$path/$sample/freec/");

open (DATA,">config_WGS.txt") || die "cannot open file";
$config = <<EOF;
[general]

chrLenFile = /project/GP1/jimmy200340/Reference/ref_GRCh38/genome.fa.fai
ploidy = 2
breakPointThreshold =0.08
window = 10000 
chrFiles = /project/GP1/jimmy200340/Reference/ref_GRCh38
numberOfProcesses = 40
sambamba = /pkg/biology/sambamba/sambamba_v0.6.7/sambamba
SambambaThreads = 40
EOF

$config2 = <<EOF;
forceGCcontentNormalization = 1
sex=XY

[sample]
EOF

$config3 = <<EOF;
inputFormat = BAM
matesOrientation = FR

[control]

[target]
EOF

print DATA "$config";
print DATA "\n";
print DATA "outputDir = $path/$sample/freec/";
print DATA "\n";
print DATA "$config2";
print DATA "\n";
print DATA "mateFile = $path/$sample/$sample.mark.sort.bam";
print DATA "\n";
print DATA "$config3";
chdir $path;
}

#create PBS client object
my $pbs = PBS::Client->new();

foreach $sample(@sample)
{
	
	$readgroup = $RG1.$sample.$RG2;
		
	#BWA & Mark Duplicates
	my $sample_bwa = PBS::Client::Job->new
	(
		queue => 'ngs192G',
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
		queue => 'ngs192G',
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
		queue => 'ngs192G',
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
		queue => 'ngs192G',
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
		queue => 'ngs192G',
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
		queue => 'ngs192G',
		name => "$sample.strelka",
		project => "MST107119",
		group => "MST107119",
		ofile => "$sample.strelka.std",
		efile => "$sample.strelka.err",
		cmd => "cd $path/$sample/StrelkaGermlineWorkflow/ ; ./runWorkflow.py --mode=local --jobs=$core",
	);
	
	
	#MoveLOG
	my $sample_mvlog = PBS::Client::Job->new
	(
		queue => 'ngs192G',
		name => "$sample.mvlog",
		project => "MST107119",
		group => "MST107119",
		cmd => "cd $path ; mv $sample*.std $path/$sample ; mv $sample*.err $path/$sample",
	);
	
	#Set Job Dependency
	$sample_bwa->next({ok => $sample_sort});
	$sample_sort->next({ok => $sample_index});
	$sample_index->next({ok => $sample_move});
	$sample_move->next({ok => $sample_prestrelka});
	$sample_prestrelka->next({ok => $sample_strelka});
	
	#Send Jobs into Queue
	$pbs->qsub($sample_bwa);
}