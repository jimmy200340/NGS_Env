#my $reference = "/work6/PMFP/u00ccl01/reference_GRCh38/hs38DH.fa";
my $reference = "/work6/PMFP/u00ccl01/ref_hg19/genome.fa";
my $path = "/work6/PMFP/u00ccl01/Special_D14768";


system ("bcl2fastq --loading-threads 10 --processing-threads 20 --writing-threads 10 --ignore-missing-bcls --ignore-missing-filter --ignore-missing-positions --ignore-missing-controls --auto-set-to-zero-barcode-mismatches --find-adapters-with-sliding-window --adapter-stringency 0.9 --mask-short-adapter-reads 35 --minimum-trimmed-read-length 35");