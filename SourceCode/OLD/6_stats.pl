my $path = "/work2/jimmy200340/181009_patched";
chdir $path;
my @sample = `ls | cut -d "_" -f1,2 | uniq`;
my $BND = "0";
my $INV = "0";
my $DEL = "0";
my $INS = "0";
my $DUP = "0";
my $loss = "0";
my $gain = "0";
open (DATA,">stats.txt")|| die "cannot open file";
print DATA "Sample ID\tBreak-end Translocations\tInversions\tDeletions\tInsertions\tDuplications\tCopy Number Losses\tCopy Number Gains\n";


foreach $sample(@sample)
{
chomp $sample;
chdir ("$path/$sample/MantaWorkflow/results/variants/");
$BND = `zcat diploidSV.vcf.gz |grep MantaBND |wc -l`;
chomp $BND;
$INV = `zcat diploidSV.vcf.gz |grep MantaINV |wc -l`;
chomp $INV;
$DEL = `zcat diploidSV.vcf.gz |grep MantaDEL |wc -l`;
chomp $DEL;
$INS = `zcat diploidSV.vcf.gz |grep MantaINS |wc -l`;
chomp $INS;
$DUP = `zcat diploidSV.vcf.gz |grep MantaDUP |wc -l`;
chomp $DUP;
chdir ("$path/$sample/freec/");
$loss =`grep loss $sample.mark.sort.bam_CNVs |wc -l`;
chomp $loss;
$gain =`grep gain $sample.mark.sort.bam_CNVs |wc -l`;
chomp $gain;
print DATA "$sample\t$BND\t$INV\t$DEL\t$INS\t$DUP\t$loss\t$gain\n";
chdir $path;
}
