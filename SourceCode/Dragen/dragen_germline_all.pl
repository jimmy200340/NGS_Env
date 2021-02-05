my $path = "/work2/jimmy200340/Dragen/TLCRC/run";
chdir $path;
my @sample = `ls | cut -d "_" -f1,2 | uniq`;

foreach $sample(@sample)
{
	chomp $sample;
	system ("mkdir /work2/jimmy200340/Dragen/TLCRC/$sample\_germline ; dragen -r /staging/human/reference/GRCh38/ --output-directory /work2/jimmy200340/Dragen/TLCRC/$sample\_germline/ --output-file-prefix $sample -1 /work2/jimmy200340/Dragen/TLCRC/run/$sample\_R1_001.fastq.gz -2 /work2/jimmy200340/Dragen/TLCRC/run/$sample\_R2_001.fastq.gz --RGSM $sample --RGID NovaSeq --enable-variant-caller true --enable-map-align-output true --enable-bam-indexing true --output-format=bam --enable-duplicate-marking true --enable-cnv true --cnv-enable-self-normalization true --cnv-enable-plot true --enable-sv true --sv-reference=/staging/human/reference/GRCh38/GRCh38.fa > /work2/jimmy200340/Dragen/TLCRC/$sample\_germline/screenlog 2>&1");
}


#cp -r --no-preserve=mode,ownership /staging/jimmy200340/DDID/$sample /NovaSeq/Dragen_jimmy200340/ ; rm -f /staging/jimmy200340/DDID/$sample