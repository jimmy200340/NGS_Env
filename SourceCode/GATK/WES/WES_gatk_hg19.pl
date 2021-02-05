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
my $RG1 = '"@RG\tID:';
my $RG2 = '\tSM:';
my $RG3 = '\tPL:illumina"'; 

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
	$readgroup = $RG1.$sample.$RG2.$sample.$RG3;
	
	#Create directory
	system ("mkdir $sample/bam");
	system ("mkdir $sample/clean_reads");
	system ("mkdir $sample/final_bam");
	system ("mkdir $sample/vcf");
	system ("mkdir $sample/qc_raw_reads");
	system ("mkdir $sample/qc_clean_reads");
	system ("mkdir $sample/qc_bam");
	system ("mkdir $sample/report");
	
	#fastqc
	system ("fastqc --outdir $path/$sample/qc_raw_reads -f fastq --extract --threads $core *.gz");
	
	#trimmomatic
	system ("java $ram -jar /home/jimmy200340/opt/Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 40 $path/$sample\_R1.fq.gz $path/$sample\_R2.fq.gz $path/$sample/clean_reads/$sample\_P_R1.fastq.gz $path/$sample/clean_reads/$sample\_U_R1.fastq.gz $path/$sample/clean_reads/$sample\_P_R2.fastq.gz $path/$sample/clean_reads/$sample\_U_R2.fastq.gz ILLUMINACLIP:$adapter:2:30:10 SLIDINGWINDOW:4:15 LEADING:20 TRAILING:20 CROP:150 MINLEN:50");
	
	#post_fastqc
	system ("fastqc --outdir $path/$sample/qc_clean_reads -f fastq --extract --threads $core $path/$sample/clean_reads/*.gz");
	
	#BWA & Markdup
	system ("bwa mem -t $core -M -R $readgroup $reference $path/$sample/clean_reads/$sample\_P_R1.fastq.gz $path/$sample/clean_reads/$sample\_P_R2.fastq.gz | samblaster -M -e | samtools view -bS -o $path/$sample/$sample.bam -");

	#Sort & Index
	system ("samtools sort -@ $core -o $path/$sample/$sample.mark.sort.bam $path/$sample/$sample.bam");
	system ("samtools index -@ $core $path/$sample/$sample.mark.sort.bam");

	#Hybrid-selection metrics
	system ("java $ram -jar $picard/picard.jar CollectHsMetrics -I $path/$sample/$sample.mark.sort.bam -O $path/$sample/$sample\_hs_metrics.txt -R $reference -BAIT_INTERVALS $twist -TARGET_INTERVALS $twist");

	#BQSR
	system ("gatk BaseRecalibrator -R $reference --known-sites $resource/dbsnp_138.hg19.vcf --known-sites $resource/1000G_phase1.indels.hg19.sites.vcf --known-sites $resource/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf -I $path/$sample/$sample.mark.sort.bam -O $path/$sample/$sample\_Recalibrated.table");
	
	system ("gatk ApplyBQSR -R $reference -I $path/$sample/$sample.mark.sort.bam --bqsr-recal-file $path/$sample/$sample\_Recalibrated.table -O $path/$sample/$sample.mark.sort.recal.bam");
	
	#pileup
	system ("bcftools mpileup --threads $core --fasta-ref $reference $path/$sample/$sample.mark.sort.recal.bam -o $path/$sample/$sample.pileup");
	
	#HplotypeCaller
	system ("gatk HaplotypeCaller --native-pair-hmm-threads 40 -R $reference -I $path/$sample/$sample.mark.sort.recal.bam -O $path/$sample/$sample.g.vcf.gz -ERC GVCF -G AS_StandardAnnotation");
	
	system ("gatk HaplotypeCaller --native-pair-hmm-threads 40 -R $reference -I $path/$sample/$sample.mark.sort.recal.bam -ERC GVCF -A AlleleFraction -A BaseQuality -A BaseQualityRankSumTest -A ChromosomeCounts -A Coverage -A DepthPerAlleleBySample -A DepthPerSampleHC -A ExcessHet -A FisherStrand -A GenotypeSummaries -A MappingQuality -A MappingQualityRankSumTest -A QualByDepth -A StrandBiasBySample -A TandemRepeat -RF GoodCigarReadFilter -RF MappedReadFilter -RF MappingQualityAvailableReadFilter -RF NotDuplicateReadFilter -RF NotSecondaryAlignmentReadFilter -O $path/$sample/$sample.raw.g.vcf");
	
	#GenotypeGVCFs
	system ("gatk GenotypeGVCFs -R $reference --standard-min-confidence-threshold-for-calling 30.0 --indel-heterozygosity 1.25E-4 --heterozygosity 0.001 --variant $path/$sample/$sample.raw.g.vcf -O $path/$sample/$sample.raw.vcf");
	
	#VQSR-SNP
	system ("gatk VariantRecalibrator -R $reference -V $path/$sample/$sample.raw.vcf --resource:hapmap,known=false,training=true,truth=true,prior=15.0 $resource/hapmap_3.3.hg19.sites.vcf --resource:omni,known=false,training=true,truth=false,prior=12.0 $resource/1000G_omni2.5.hg19.sites.vcf --resource:1000G,known=false,training=true,truth=false,prior=10.0 $resource/1000G_phase1.snps.high_confidence.hg19.sites.vcf --resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $resource/dbsnp_138.hg19.vcf -an QD -an DP -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR -mode SNP --max-gaussians 2 -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 95.0 -tranche 90.0 --tranches-file $path/$sample/$sample.snps.trances --rscript-file $path/$sample/$sample.snps.plots.R -O $path/$sample/$sample.snps.recal");
	
	system ("gatk ApplyVQSR -R $reference -V $path/$sample/$sample.raw.vcf --truth-sensitivity-filter-level 99.0 --tranches-file $path/$sample/$sample.snps.trances --recal-file $path/$sample/$sample.snps.recal -mode SNP -O $path/$sample/$sample.phased.filtered_snp.vcf");
	
	#VQSR-INDEL
	system ("gatk VariantRecalibrator -R $reference -V $path/$sample/$sample.phased.filtered_snp.vcf --resource:mills,known=true,training=true,truth=true,prior=12.0 $resource/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf --resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $resource/dbsnp_138.hg19.vcf -an QD -an DP -an MQRankSum -an ReadPosRankSum -an FS -an SOR -mode INDEL --max-gaussians 4 --tranches-file $path/$sample/$sample.indels.tranches --rscript-file $path/$sample/$sample.indels.plots.R -O $path/$sample/$sample.snps.indels.recal");
	
	system ("gatk ApplyVQSR -R $reference -V $path/$sample/$sample.phased.filtered_snp.vcf --truth-sensitivity-filter-level 99.0 --tranches-file $path/$sample/$sample.indels.tranches --recal-file $path/$sample/$sample.snps.indels.recal -mode INDEL -O $path/$sample/$sample.phased.filtered_snps_indels.vcf");
	
	#Select
	system ("gatk SelectVariants -R $reference -V $path/$sample/$sample.phased.filtered_snps_indels.vcf --exclude-filtered -O $path/$sample/$sample.exclude_filtered.vcf");

	system ("gatk SelectVariants -R $reference -V $path/$sample/$sample.phased.filtered_snps_indels.vcf --select-type-to-include SNP -O $path/$sample/$sample.exclude_filtered_snp.vcf");

	system ("gatk SelectVariants -R $reference -V $path/$sample/$sample.phased.filtered_snps_indels.vcf --select-type-to-include INDEL -O $path/$sample/$sample.exclude_filtered_indel.vcf");
	
	###annotation
	##SNP
	#annovar
	system ("$annovar/table_annovar.pl $path/$sample/$sample.exclude_filtered_snp.vcf $annovar/humandb/ -buildver hg19 -out $path/$sample/$sample.annovar.exclude_filtered_snp -remove -protocol refGene,ensGene,cytoBand,wgRna,targetScanS,tfbsConsSites,genomicSuperDups,rmsk,avsnp150,cosmic70,clinvar_20200316,1000g2015aug_eas,1000g2015aug_sas,1000g2015aug_eur,1000g2015aug_afr,1000g2015aug_amr,1000g2015aug_all,gnomad_exome,esp6500siv2_all,exac03,dbnsfp35a,gwasCatalog -argument '-splicing_threshold 10','-splicing_threshold 10',,,,,,,,,,,,,,,,,,,, -operation  g,g,r,r,r,r,r,r,f,f,f,f,f,f,f,f,f,f,f,f,f,r -nastring . -vcfinput");
	
	$annovar_snp = "$path/$sample/$sample.annovar.exclude_filtered_snp.hg19_multianno.txt";
	
	#InterVar
	system ("python $annovar/InterVar/Intervar.py -b hg19 -i $path/$sample/$sample.exclude_filtered_snp.vcf --input_type=VCF -o $path/$sample/$sample.intervar.exclude_filtered_snp");
	
	$intervar_snp = "$path/$sample/$sample.intervar.exclude_filtered_snp.hg19_multianno.txt.intervar";
	
	#snpEFF	
	system ("$snpeff GRCh37.75 -csvStats $path/$sample/$sample.csv $path/$sample/$sample.exclude_filtered.vcf");
	
	system ("$snpeff GRCh37.75 -noStats $path/$sample/$sample.exclude_filtered_snp.vcf > $path/$sample/$sample.exclude_filtered_snp.eff.vcf");
	
	#Gene Ontology Biology Process
	system ("$snpsift geneSets -v $gene/c5.go.bp.v7.2.symbols.gmt $path/$sample/$sample.exclude_filtered_snp.eff.vcf > $path/$sample/$sample.exclude_filtered_snp.eff.bp.vcf");
	
	$snp_bp = "$path/$sample/$sample.exclude_filtered_snp.eff.bp.vcf";
	
	#Gene Ontology Cellular Component
	system ("$snpsift geneSets -v $gene/c5.go.cc.v7.2.symbols.gmt $path/$sample/$sample.exclude_filtered_snp.eff.vcf > $path/$sample/$sample.exclude_filtered_snp.eff.cc.vcf");
	
	$snp_cc = "$path/$sample/$sample.exclude_filtered_snp.eff.cc.vcf";
	
	#Gene Ontology Molecular Function
	system ("$snpsift geneSets -v $gene/c5.go.mf.v7.2.symbols.gmt $path/$sample/$sample.exclude_filtered_snp.eff.vcf > $path/$sample/$sample.exclude_filtered_snp.eff.mf.vcf");
	
	$snp_mf = "$path/$sample/$sample.exclude_filtered_snp.eff.mf.vcf";
	
	#Curated Gene Canonical Pathway KEGG
	system ("$snpsift geneSets -v $gene/c2.cp.kegg.v7.2.symbols.gmt $path/$sample/$sample.exclude_filtered_snp.eff.vcf > $path/$sample/$sample.exclude_filtered_snp.eff.kegg.vcf");
	
	$snp_kegg = "$path/$sample/$sample.exclude_filtered_snp.eff.kegg.vcf";
	
	#Curated Gene Canonical Pathway PID
	system ("$snpsift geneSets -v $gene/c2.cp.pid.v7.2.symbols.gmt $path/$sample/$sample.exclude_filtered_snp.eff.vcf > $path/$sample/$sample.exclude_filtered_snp.eff.pid.vcf");
	
	$snp_pid = "$path/$sample/$sample.exclude_filtered_snp.eff.pid.vcf";
	
	#Curated Gene Canonical Pathway BIOCARTA
	system ("$snpsift geneSets -v $gene/c2.cp.biocarta.v7.2.symbols.gmt $path/$sample/$sample.exclude_filtered_snp.eff.vcf > $path/$sample/$sample.exclude_filtered_snp.eff.biocarta.vcf");
	
	$snp_biocarta = "$path/$sample/$sample.exclude_filtered_snp.eff.biocarta.vcf";
	
	#Curated Gene Canonical Pathway REACTOME
	system ("$snpsift geneSets -v $gene/c2.cp.reactome.v7.2.symbols.gmt $path/$sample/$sample.exclude_filtered_snp.eff.vcf > $path/$sample/$sample.exclude_filtered_snp.eff.reactome.vcf");
	
	$snp_reactome = "$path/$sample/$sample.exclude_filtered_snp.eff.reactome.vcf";
	$snp_result_vcf = "$path/$sample/report/$sample\_GATK.snp.hg19_multianno.vcf";
	
	##INDEL
	#annovar
	system ("$annovar/table_annovar.pl $path/$sample/$sample.exclude_filtered_indel.vcf $annovar/humandb/ -buildver hg19 -out $path/$sample/$sample.annovar.exclude_filtered_indel -remove -protocol refGene,ensGene,cytoBand,wgRna,targetScanS,tfbsConsSites,genomicSuperDups,rmsk,avsnp150,cosmic70,clinvar_20200316,1000g2015aug_eas,1000g2015aug_sas,1000g2015aug_eur,1000g2015aug_afr,1000g2015aug_amr,1000g2015aug_all,gnomad_exome,esp6500siv2_all,exac03,dbnsfp35a,gwasCatalog -argument '-splicing_threshold 10','-splicing_threshold 10',,,,,,,,,,,,,,,,,,,, -operation  g,g,r,r,r,r,r,r,f,f,f,f,f,f,f,f,f,f,f,f,f,r -nastring . -vcfinput");
	
	$annovar_indel = "$path/$sample/$sample.annovar.exclude_filtered_indel.hg19_multianno.txt";
	
	#Invervar
	system ("python $annovar/InterVar/Intervar.py -b hg19 -i $path/$sample/$sample.exclude_filtered_indel.vcf --input_type=VCF -o $path/$sample/$sample.intervar.exclude_filtered_indel");
	
	$intervar_indel = "$path/$sample/$sample.intervar.exclude_filtered_indel.hg19_multianno.txt.intervar";
	
	#snpEFF
	system ("$snpeff GRCh37.75 -noStats $path/$sample/$sample.exclude_filtered_indel.vcf > $path/$sample/$sample.exclude_filtered_indel.eff.vcf");
	
	#Gene Ontology Biology Process
	system ("$snpsift geneSets -v $gene/c5.go.bp.v7.2.symbols.gmt $path/$sample/$sample.exclude_filtered_indel.eff.vcf > $path/$sample/$sample.exclude_filtered_indel.eff.bp.vcf");
	
	$indel_bp = "$path/$sample/$sample.exclude_filtered_indel.eff.bp.vcf";
	
	#Gene Ontology Cellular Component
	system ("$snpsift geneSets -v $gene/c5.go.cc.v7.2.symbols.gmt $path/$sample/$sample.exclude_filtered_indel.eff.vcf > $path/$sample/$sample.exclude_filtered_indel.eff.cc.vcf");
	
	$indel_cc = "$path/$sample/$sample.exclude_filtered_indel.eff.cc.vcf";
	
	#Gene Ontology Molecular Function
	system ("$snpsift geneSets -v $gene/c5.go.mf.v7.2.symbols.gmt $path/$sample/$sample.exclude_filtered_indel.eff.vcf > $path/$sample/$sample.exclude_filtered_indel.eff.mf.vcf");
	
	$indel_mf = "$path/$sample/$sample.exclude_filtered_indel.eff.mf.vcf";
	
	#Curated Gene Canonical Pathway KEGG
	system ("$snpsift geneSets -v $gene/c2.cp.kegg.v7.2.symbols.gmt $path/$sample/$sample.exclude_filtered_indel.eff.vcf > $path/$sample/$sample.exclude_filtered_indel.eff.kegg.vcf");
	
	$indel_kegg = "$path/$sample/$sample.exclude_filtered_indel.eff.kegg.vcf";
	
	#Curated Gene Canonical Pathway PID
	system ("$snpsift geneSets -v $gene/c2.cp.pid.v7.2.symbols.gmt $path/$sample/$sample.exclude_filtered_indel.eff.vcf > $path/$sample/$sample.exclude_filtered_indel.eff.pid.vcf");
	
	$indel_pid = "$path/$sample/$sample.exclude_filtered_indel.eff.pid.vcf";
	
	#Curated Gene Canonical Pathway BIOCARTA
	system ("$snpsift geneSets -v $gene/c2.cp.biocarta.v7.2.symbols.gmt $path/$sample/$sample.exclude_filtered_indel.eff.vcf > $path/$sample/$sample.exclude_filtered_indel.eff.biocarta.vcf");
	
	$indel_biocarta = "$path/$sample/$sample.exclude_filtered_indel.eff.biocarta.vcf";
	
	#Curated Gene Canonical Pathway REACTOME
	system ("$snpsift geneSets -v $gene/c2.cp.reactome.v7.2.symbols.gmt $path/$sample/$sample.exclude_filtered_indel.eff.vcf > $path/$sample/$sample.exclude_filtered_indel.eff.reactome.vcf");
	
	$indel_reactome = "$path/$sample/$sample.exclude_filtered_indel.eff.reactome.vcf";
	$indel_result_vcf = "$path/$sample/report/$sample\_GATK.indel.hg19_multianno.vcf";
	
	#vcf post-processing 
	system ("Rscript $rpath/post_vcf.r --sample $sample --annovar-snp $annovar_snp --intervar-snp $intervar_snp --snp-bp $snp_bp --snp-cc $snp_cc --snp-mf $snp_mf --snp-kegg $snp_kegg --snp-pid $snp_pid --snp-biocarta $snp_biocarta --snp-reactome $snp_reactome --snp-vcf $snp_result_vcf --annovar-indel $annovar_indel --intervar-indel $intervar_indel --indel-bp $indel_bp --indel-cc $indel_cc --indel-mf $indel_mf --indel-kegg $indel_kegg --indel-pid $indel_pid --indel-biocarta $indel_biocarta --indel-reactome $indel_reactome --indel-vcf $indel_result_vcf");
	
	#CNV Control-FREEC-11
	chdir ("$path/$sample/freec/");
	system ("freec -conf config_WES.txt");
	
	#Move
	#system ("mv $path/$sample/$sample.mark.sort.recal.bam $path/$sample/final_bam/");
	#system ("mv $path/$sample/*vcf $path/$sample/vcf/");
}