#!/usr/bin/perl

#Module to use

#Executable path
my $snpeff = "/home/jimmy200340/opt/snpEff/exec/snpeff";
my $snpsift = "/home/jimmy200340/opt/snpEff/exec/snpsift";
my $annovar = "/home/jimmy200340/opt/annovar";
my $picard = "/home/jimmy200340/opt/Picard";

#refernce version
my $ref19 = "/home/jimmy200340/NGStools/reference/ucsc_hg19/ucsc.hg19.fasta";

#HS metric file (Agilent SureSelect/Twist Bioscience)
my $twist = "/home/jimmy200340/NGStools/reference/wes_target/twist/Twist_Exome_RefSeq_targets_hg19_0.Interval";
my $sureselect = "/home/jimmy200340/NGStools/reference/wes_target/sureselect/Covered.interval_list";

#region_bed
my $twist_bed = "/home/jimmy200340/NGStools/reference/wes_target/twist/Twist_Exome_RefSeq_targets_hg19_0.bed";
my $surselect_bed = "/home/jimmy200340/NGStools/reference/wes_target/sureselect/S07604514_Covered.bed";

#Gene_dir
my $gene = "/home/jimmy200340/NGStools/genes";

#sample path
my $path = "/home/jimmy200340/work/test";

#Rscript path
my $rpath = "/home/jimmy200340/work";

#Resource path
my $resource = "/home/jimmy200340/NGStools/reference";

#trimmomatic
my $adapter = "/home/jimmy200340/NGStools/reference/trimmomatic/TruSeq3-PE-2.fa";
#
#Sample names
chdir $path;
my @sample = `ls | cut -d "_" -f1,2 |uniq`;

#readgroup
my $RG1 = '"@RG\tID:NovaSeq\tSM:';
my $RG2 = '\tPL:illumina"'; 

#CPU core
my $core = "40";

#Java RAM
my $ram = "-Xmx180g";

#reference to use
my $reference = $ref19;

#genome to use
#my $genome = $NCBI_Ref_38;

#freec_conf
foreach $sample(@sample)
{
chomp $sample;
system ("mkdir $sample");
chdir $sample;
mkdir freec;
chdir ("$path/$sample/freec/");

open (DATA,">config_WES.txt") || die "cannot open file";
$config = <<EOF;
[general]

chrLenFile = /home/jimmy200340/NGStools/reference/ucsc_hg19/CNV.ucsc.hg19.fasta.fai
window = 0
ploidy = 2
sex=XY
chrFiles = /home/jimmy200340/NGStools/reference/ucsc_hg19
numberOfProcesses = 40
sambamba = /home/jimmy200340/opt/sambamba/sambamba
SambambaThreads = 40
EOF

$config2 = <<EOF;
degree =1
minCNAlength=3
forceGCcontentNormalization = 1
breakPointThreshold =1.2
noisyData=TRUE
printNA=FALSE
readCountThreshold=50


[sample]
EOF

$config3 = <<EOF;
inputFormat = BAM
matesOrientation = FR


[control]

[BAF]
makePileup = /home/jimmy200340/opt/FREEC-11.6/hg19_snp142.SingleDiNucl.1based.bed
SNPfile = /home/jimmy200340/opt/FREEC-11.6/hg19_snp142.SingleDiNucl.1based.txt
minimalCoveragePerPosition = 5
minimalQualityPerPosition = 0
shiftInQuality = 33
fastaFile=/home/jimmy200340/NGStools/reference/ucsc_hg19/ucsc.hg19.fasta
EOF

$config4 = <<EOF;
[target]

EOF

print DATA "$config";
print DATA "\n";
print DATA "outputDir = $path/$sample/freec/";
print DATA "\n";
print DATA "$config2";
print DATA "\n";
print DATA "mateFile = $path/$sample/$sample.mark.sort.recal.bam";
print DATA "\n";
print DATA "miniPileup = $path/$sample/$sample.pileup";
print DATA "\n";
print DATA "$config3";
print DATA "\n";
print DATA "$config4";
print DATA "\n";
print DATA "captureRegions = $surselect_bed";
print DATA "\n";
chdir $path;
}
