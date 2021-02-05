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
my $path = "/home/jimmy200340/work/wgs_test";

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
my @vcf_path = "";
#Library

#readgroup
my $RG1 = '"@RG\tID:'; 
my $RG2 = '\tSM:';
my $RG3 = '\tLB:';
my $RG4 = '\tPL:illumina"'; 

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
fastaFile=/home/chiashan/bundle/ucsc_hg19/ucsc.hg19.fasta

[target]
EOF

$config4 = <<EOF;

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


foreach $sample(@sample)
{
	chomp $sample;
	chdir $path;
	$readgroup = $RG1.$sample.$RG2.$sample.$RG4;
	
	#Create directory
	system ("mkdir $sample/bam");
	system ("mkdir $sample/clean_reads");
	system ("mkdir $sample/final_bam");
	system ("mkdir $sample/vcf");
	system ("mkdir $sample/qc_raw_reads");
	system ("mkdir $sample/qc_clean_reads");
	system ("mkdir $sample/qc_bam");
	system ("mkdir $sample/report");
	#system ("mkdir joint_calling");
	#system ("mkdir joint_calling/database");
		
	#fastqc
	#system ("fastqc --outdir $path/$sample/qc_raw_reads -f fastq --extract --threads $core *.gz");
	
	#trimmomatic
	#system ("java $ram -jar /home/jimmy200340/opt/Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 40 $path/$sample\_R1.fq.gz $path/$sample\_R2.fq.gz $path/$sample/clean_reads/$sample\_P_R1.fastq.gz $path/$sample/clean_reads/$sample\_U_R1.fastq.gz $path/$sample/clean_reads/$sample\_P_R2.fastq.gz $path/$sample/clean_reads/$sample\_U_R2.fastq.gz ILLUMINACLIP:$adapter:2:30:10 LEADING:30 TRAILING:30 CROP:150 MINLEN:50");
	
	#post_fastqc
	#system ("fastqc --outdir $path/$sample/qc_clean_reads -f fastq --extract --threads $core $path/$sample/clean_reads/*.gz");
	
	#BWA & Markdup
	#system ("bwa mem -t $core -M -R $readgroup $reference $path/$sample/clean_reads/$sample\_P_R1.fastq.gz $path/$sample/clean_reads/$sample\_P_R2.fastq.gz | samblaster -M -e | samtools view -bS -o $path/$sample/$sample.bam -");

	#Sort & Index
	#system ("samtools sort -@ $core -o $path/$sample/$sample.mark.sort.bam $path/$sample/$sample.bam");
	#system ("samtools index -@ $core $path/$sample/$sample.mark.sort.bam");

	#Qualimap
	system ("qualimap bamqc --java-mem-size=192G -bam $path/$sample/$sample.mark.sort.bam -outdir $path/$sample/$sample -outformat HTML -outfile $sample");

	#BQSR
	#system ("gatk --java-options '$ram' BaseRecalibrator -R $reference --known-sites $resource/dbsnp_138.hg19.vcf --known-sites $resource/1000G_phase1.indels.hg19.sites.vcf --known-sites $resource/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf -I $path/$sample/$sample.mark.sort.bam -O $path/$sample/$sample\_Recalibrated.table");
	
	#system ("gatk --java-options '$ram' ApplyBQSR -R $reference -I $path/$sample/$sample.mark.sort.bam --bqsr-recal-file $path/$sample/$sample\_Recalibrated.table -O $path/$sample/$sample.mark.sort.recal.bam");
		
	#HplotypeCaller
	#system ("gatk --java-options '$ram' HaplotypeCaller --native-pair-hmm-threads 40 -R $reference -I $path/$sample/$sample.mark.sort.recal.bam -O $path/$sample/$sample.g.vcf.gz -ERC GVCF -G AS_StandardAnnotation -G StandardAnnotation -G StandardHCAnnotation");
	
	#system ("gatk --java-options '$ram' HaplotypeCaller --native-pair-hmm-threads 40 -R $reference -I $path/$sample/$sample.mark.sort.recal.bam -ERC GVCF -A AlleleFraction -A BaseQuality -A BaseQualityRankSumTest -A ChromosomeCounts -A Coverage -A DepthPerAlleleBySample -A DepthPerSampleHC -A ExcessHet -A FisherStrand -A GenotypeSummaries -A MappingQuality -A MappingQualityRankSumTest -A QualByDepth -A StrandBiasBySample -A TandemRepeat -RF GoodCigarReadFilter -RF MappedReadFilter -RF MappingQualityAvailableReadFilter -RF NotDuplicateReadFilter -RF NotSecondaryAlignmentReadFilter -O $path/$sample/$sample.raw.g.vcf");
	
	#GenotypeGVCFs
	#system ("gatk --java-options '$ram' GenotypeGVCFs -R $reference --standard-min-confidence-threshold-for-calling 30.0 --indel-heterozygosity 1.25E-4 --heterozygosity 0.001 --variant $path/$sample/$sample.raw.g.vcf -O $path/$sample/$sample.raw.vcf");
	
	#VQSR-SNP
	#system ("gatk --java-options '$ram' VariantRecalibrator -R $reference -V $path/$sample/$sample.raw.vcf --resource:hapmap,known=false,training=true,truth=true,prior=15.0 $resource/hapmap_3.3.hg19.sites.vcf --resource:omni,known=false,training=true,truth=false,prior=12.0 $resource/1000G_omni2.5.hg19.sites.vcf --resource:1000G,known=false,training=true,truth=false,prior=10.0 $resource/1000G_phase1.snps.high_confidence.hg19.sites.vcf --resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $resource/dbsnp_138.hg19.vcf -an QD -an DP -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR -mode SNP --max-gaussians 4 -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 95.0 -tranche 90.0 --tranches-file $path/$sample/$sample.snps.trances --rscript-file $path/$sample/$sample.snps.plots.R -O $path/$sample/$sample.snps.recal");
	
	#system ("gatk --java-options '$ram' ApplyVQSR -R $reference -V $path/$sample/$sample.raw.vcf --truth-sensitivity-filter-level 99.0 --tranches-file $path/$sample/$sample.snps.trances --recal-file $path/$sample/$sample.snps.recal -mode SNP -O $path/$sample/$sample.phased.filtered_snp.vcf");
	
	#VQSR-INDEL
	#system ("gatk --java-options '$ram' VariantRecalibrator -R $reference -V $path/$sample/$sample.phased.filtered_snp.vcf --resource:mills,known=true,training=true,truth=true,prior=12.0 $resource/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf --resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $resource/dbsnp_138.hg19.vcf -an QD -an DP -an MQRankSum -an ReadPosRankSum -an FS -an SOR -mode INDEL --max-gaussians 4 --tranches-file $path/$sample/$sample.indels.tranches --rscript-file $path/$sample/$sample.indels.plots.R -O $path/$sample/$sample.snps.indels.recal");
	
	#system ("gatk --java-options '$ram' ApplyVQSR -R $reference -V $path/$sample/$sample.phased.filtered_snp.vcf --truth-sensitivity-filter-level 99.0 --tranches-file $path/$sample/$sample.indels.tranches --recal-file $path/$sample/$sample.snps.indels.recal -mode INDEL -O $path/$sample/$sample.phased.filtered_snps_indels.vcf");	
}	


	foreach $sample(@sample)
	{
		#push (@vcf_path ,("-V $path/$sample/$sample.g.vcf.gz"));
	}
	
	for ($i=1, $i<22, $i++)
	{
		#system ("gatk --java-options '$ram' GenomicsDBImport @vcf_path --genomicsdb-workspace-path $path/joint_calling/chr$i --tmp-dir=$path/joint_calling/temp -L chr$i");
		#system ("gatk --java-options '$ram' GenotypeGVCFs -R $reference -V gendb:///$path/joint_calling/chr$i -O $path/joint_calling/final_chr$i.vcf");
	}
		#system ("gatk --java-options '$ram' GenomicsDBImport @vcf_path --genomicsdb-workspace-path $path/joint_calling/chrX --tmp-dir=$path/joint_calling/temp -L chrX");
		#system ("gatk --java-options '$ram' GenotypeGVCFs -R $reference -V gendb:///$path/joint_calling/chrX -O $path/joint_calling/final_chrX.vcf");
		
		#system ("gatk --java-options '$ram' GenomicsDBImport @vcf_path --genomicsdb-workspace-path $path/joint_calling/chrY --tmp-dir=$path/joint_calling/temp -L chrY");
		#system ("gatk --java-options '$ram' GenotypeGVCFs -R $reference -V gendb:///$path/joint_calling/chrY -O $path/joint_calling/final_chrY.vcf");
	
	#GatherVcfs
	for ($j=1, $j<22, $j++)
	{
		push (@vcf_final_path ,("-I $path/joint_calling/final_chr$j.vcf"))
	}
	#system ("gatk --java-options '$ram' GatherVcfs @vvcf_final_path -I $path/joint_calling/final_chrX.vcf -I $path/joint_calling/final_chrY.vcf -O $path/joint_calling/joint.vcf");
	
	#VQSR-SNP
	#system ("gatk --java-options '$ram' VariantRecalibrator -R $reference -V $path/joint_calling/joint.vcf --resource:hapmap,known=false,training=true,truth=true,prior=15.0 $resource/hapmap_3.3.hg19.sites.vcf --resource:omni,known=false,training=true,truth=false,prior=12.0 $resource/1000G_omni2.5.hg19.sites.vcf --resource:1000G,known=false,training=true,truth=false,prior=10.0 $resource/1000G_phase1.snps.high_confidence.hg19.sites.vcf --resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $resource/dbsnp_138.hg19.vcf -an QD -an DP -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR -mode SNP --max-gaussians 4 -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 95.0 -tranche 90.0 --tranches-file $path/joint_calling/joint.snp.tranches -O $path/joint_calling/joint.snp.recal");
	#system ("gatk --java-options '$ram' ApplyVQSR -R $reference -V $path/joint_calling/joint.vcf -truth-sensitivity-filter-level 99.0 --tranches-file joint.snps.tranches --recal-file $path/joint_calling/joint.snp.recal -mode SNP -O $path/joint_calling/joint.phased.filtered_snps.vcf");
	
	#VQSR-INDEL
	#system("gatk --java-options '$ram' VariantRecalibrator -R $reference -V $path/joint_calling/joint.vcf --resource:mills,known=true,training=true,truth=true,prior=12.0 $resource/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf --resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $resource/dbsnp_138.hg19.vcf -an QD -an DP -an MQRankSum -an ReadPosRankSum -an FS -an SOR -mode INDEL --max-gaussians 4 --tranches-file $path/joint_calling/joint.indels.tranches -O $path/joint_calling/joint.snps.indel.recal");
	#system ("gatk --java-options '$ram' ApplyVQSR -R $reference -V $path/joint_calling/joint.phased.filtered_snps.vcf --truth-sensitivity-filter-level 99.0 --tranches-file $path/joint_calling/joint.indels.tranches --recal-file $path/joint_calling/joint.snps.indel.recal -mode INDEL -O $path/joint_calling/joint.phased.filtered_snps_indel.vcf");

	#SelectVariants
	#system ("gatk --java-options '$ram' SelectVariants -R $reference -V $path/joint_calling/joint.phased.filtered_snps_indel.vcf --exclude-filtered -O $path/joint_calling/joint_exclude_filtered.vcf");
	#system ("gatk --java-options '$ram' SelectVariants -R $reference -V $path/joint_calling/joint_exclude_filtered.vcf --select-type-to-include SNP -O $path/joint_calling/joint_exclude_filtered_snp.vcf");
	#system ("gatk --java-options '$ram' SelectVariants -R $reference -V $path/joint_calling/joint_exclude_filtered.vcf --select-type-to-include INDEL -O $path/joint_calling/joint_exclude_filtered_indel.vcf");