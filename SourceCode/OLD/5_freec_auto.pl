my $reference = "/work6/PMFP/u00ccl01/ref_hg19/genome.fa";
my $path = "/work6/PMFP/u00ccl01/TVB084";
my @sample = ("TVB084N","TVB084T");


foreach $sample(@sample)
{
chdir $sample;
mkdir freec;
chdir $path;

open (DATA,">config_WGS.txt") || die "cannot open file";
$config = <<EOF;
[general]

chrLenFile = /work6/PMFP/u00ccl01/ref_hg19/genome.fa.fai
ploidy = 2
breakPointThreshold =0.08
window = 10000 
chrFiles = /work6/PMFP/u00ccl01/ref_hg19 
numberOfProcesses = 40
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

system ("mv config_WGS.txt $path/$sample/freec/");
chdir ("$path/$sample/freec/");
system ("bsub -q 128G -o std -e err -J $sample.freec \"freec -conf config_WGS.txt\"");
chdir $path;
}
