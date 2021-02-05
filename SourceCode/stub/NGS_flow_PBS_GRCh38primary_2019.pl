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
my $ref38 = "/work2/jimmy200340/Reference/ref_GRCh38/genome.fa";
my $ref38_primary = "/work2/jimmy200340/Reference/ref_GRCh38.1/genome.fa";
my $ref19 = "/work2/jimmy200340/Reference/ref_hg19/genome.fa";

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
my $path = "/work2/u00ccl01/NV0065";

#clineff path
my $clineff = "/pkg/biology/ClinEff/ClinEff_v1.0h/";
#clineff license
my $efflicense = "/work2/jimmy200340/license/";

#sample names
chdir $path;
#my @sample = `ls | cut -d "_" -f1,2 | uniq`;
#@sample = ("NV0038-10","NV0038-14","NV0038-15","NV0038-17");

#readgroup
my $RG1 = '"@RG\\tID:NovaSeq\\tLB:NHRI\\tPL:Illumina\\tSM:';
my $RG2 = '\\tPI:150"';

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
my $reference = $ref38_primary;

#genome to use
my $genome = $NCBI_Ref_38;

#freec_conf

foreach $id (3..5)
{
  if ($id < 10)
  { $id = "0".$id; }

  my $sample = "NV0065-".$id;
system ("mkdir $sample");
chdir $sample;
mkdir freec;
chdir ("$path/$sample/freec/");

open (DATA,">config_WGS.txt") || die "cannot open file";
$config = <<EOF;
[general]

chrLenFile = /work2/jimmy200340/Reference/ref_GRCh38.1/genome.fa.fai
ploidy = 2
breakPointThreshold =0.08
window = 10000 
chrFiles = /work2/jimmy200340/Reference/ref_GRCh38.1
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

#demultiplex
#my $demultiplex = PBS::Client::Job->new
#(
#	queue => 'ngs384G',
#	name => "demultiplex",
#	project => "MST107119",
#	group => "MST107119",
#	ofile => "demultiplex.std",
#	efile => "demultiplex.err",
#	cmd => "$bcl2fastq -r 20 -p 40 -w 20 --ignore-missing-bcls --ignore-missing-filter --ignore-missing-positions --ignore-missing-controls --auto-set-to-zero-barcode-mismatches --find-adapters-with-sliding-window --adapter-stringency 0.9 --mask-short-adapter-reads 35 --minimum-trimmed-read-length 35",
#);


#fastqc
#my $fastQC = PBS::Client::Job->new
#(
#	queue => 'ngs384G',
#	name => "fastQC",
#	project => "MST107119",
#	group => "MST107119",
#	ofile => "fastqc.std",
#	efile => "fastqc.err",
#	cmd => "cd $path ; mkdir fastqc_reports ; $fastqc --outdir $path/fastqc_reports --casava --extract --format fastq --threads $core *.gz",
#);


foreach $id (3..5)
{
  if ($id < 10)
  { $id = "0".$id; }

  my $sample = "NV0065-".$id;
	
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
		cmd => "cd $path ; ~/bin/bwa mem -M -R $readgroup -t $core -K 10000000 $reference $path/$sample.R1.fastp.fq.gz $path/$sample.R1.fastp.fq.gz | $samblaster -M -e | $samtools view -bS -o $path/$sample.bam -",
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
		queue => 'ngs384G',
		name => "$sample.move",
		project => "MST107119",
		group => "MST107119",
		ofile => "$sample.move.std",
		efile => "$sample.move.err",
		cmd => "cd $path ; mv $path/$sample.mark.sort.bam $path/$sample ; mv $path/$sample.mark.sort.bam.bai $path/$sample ; rm $path/$sample.bam",
	);
	
	#Manta_Somatic_pre
	#my $sample_premanta = PBS::Client::Job->new
	#(
	#	queue => 'ngs384G',
	#	name => "$sample.premanta",
	#	project => "MST107119",
	#	group => "MST107119",
	#	ofile => "$sample.premanta.std",
	#	efile => "$sample.premanta.err",
	#	cmd => "cd $sample ; ~/bin/manta/bin/configManta.py --bam=$sample.mark.sort.bam --tumorBam=$sample.mark.sort.bam --referenceFasta=$reference",
	#);
	
	#Manta_Germline_pre
	my $sample_premanta = PBS::Client::Job->new
	(
		queue => 'ngs192G',
		name => "$sample.premanta",
		project => "MST107119",
		group => "MST107119",
		ofile => "$sample.premanta.std",
		efile => "$sample.premanta.err",
		cmd => "cd $path/$sample ; ~/bin/manta/bin/configManta.py --bam=$sample.mark.sort.bam --referenceFasta=$reference",
	);
	
	#Manta
	my $sample_manta = PBS::Client::Job->new
	(
		queue => 'ngs192G',
		name => "$sample.manta",
		project => "MST107119",
		group => "MST107119",
		ofile => "$sample.manta.std",
		efile => "$sample.manta.err",
		cmd => "cd $path/$sample/MantaWorkflow/ ; ./runWorkflow.py --mode=local --jobs=$core",
	);
	
	#Strelka_Somatic_pre
	
	#my $sample_prestrelka = PBS::Client::Job->new
	#(
	#	queue => 'ngs384G',
	#	name => "$sample.prestrelka",
	#	project => "MST107119",
	#	group => "MST107119",
	#	ofile => "$sample.prestrelka.std",
	#	efile => "$sample.prestrelka.err",
	#	cmd => "cd $sample ; ~/bin/Strelka2/bin/configureStrelkaSomaticWorkflow.py --normalBam=$sample.mark.sort.bam --tumorBam=$path/TVB084T/$sample.mark.sort.bam --indelCandidates=$path/$sample/MantaWorkflow/results/variants/candidateSmallIndels.vcf.gz --referenceFasta=$reference ; cd $path/$sample/StrelkaGermlineWorkflow/",
	#);

	
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
	
	#Control-FREEC
	my $sample_freec = PBS::Client::Job->new
	(
		queue => 'ngs192G',
		name => "$sample.freec",
		project => "MST107119",
		group => "MST107119",
		ofile => "$sample.freec.std",
		efile => "$sample.freec.err",
		cmd => "cd $path/$sample/freec/ ; $freec -conf config_WGS.txt",
	);
		
	#ClinEFF
	my $sample_preclineff = PBS::Client::Job->new
	(
		queue => 'ngs192G',
		name => "$sample.preclineff",
		project => "MST107119",
		group => "MST107119",
		ofile => "$sample.preclineff.std",
		efile => "$sample.preclineff.err",
		cmd => "cd $path/$sample/ ; mkdir $path/$sample/clineff ;cd $path/$sample/clineff/; cp -r /pkg/biology/ClinEff/ClinEff_v1.0h/report . ; cp -r /pkg/biology/ClinEff/ClinEff_v1.0h/workflow .; cp /pkg/biology/ClinEff/ClinEff_v1.0h/clinEff* .; cp /pkg/biology/ClinEff/ClinEff_v1.0h/workflow.config .; cp /pkg/biology/ClinEff/ClinEff_v1.0h/ClinEff.jar .;ln -s /pkg/biology/ClinEff/ClinEff_v1.0h/data; ln -s /pkg/biology/ClinEff/ClinEff_v1.0h/db",
	);
	
	my $sample_clineff = PBS::Client::Job->new
	(
		queue => 'ngs192G',
		name => "$sample.clineff",
		project => "MST107119",
		group => "MST107119",
		ofile => "$sample.clineff.std",
		efile => "$sample.clineff.err",
		cmd => "cd $path/$sample/clineff ; /pkg/biology/Java/jdk_10/bin/java -jar ClinEff.jar -l /work2/jimmy200340/license/clinEff.license -v $genome $path/$sample/StrelkaGermlineWorkflow/results/variants/variants.vcf.gz > $path/$sample/$sample.ann.vcf",
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
	$sample_move->next({ok => $sample_premanta});
	$sample_premanta->next({ok => $sample_manta});
	$sample_manta->next({ok => $sample_prestrelka});
	$sample_prestrelka->next({ok => $sample_strelka});
	$sample_strelka->next({ok => $sample_freec});
	#$sample_freec->next({ok => $sample_preclineff});
	#$sample_preclineff->next({ok => $sample_clineff});
	$sample_freec->next({ok => $sample_mvlog});
	
	#Send Jobs into Queue
	$pbs->qsub($sample_bwa);
}
