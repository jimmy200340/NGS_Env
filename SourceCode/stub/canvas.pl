use PBS::Client;

#create PBS client object
my $pbs = PBS::Client->new();
my $canvas = "/pkg/biology/Canvas/Canvas_v1.38.0/Canvas.dll";
my $path = "/project/GP1/jimmy200340/canvas_test";
my $ref38 = "/project/GP1/jimmy200340/Reference/ref_GRCh38/genome.fa";


#demultiplex
my $canvas = PBS::Client::Job->new
(
	queue => 'ngs384G',
	name => "demultiplex",
	project => "MST107119",
	group => "MST107119",
	ofile => "canvas.std",
	efile => "canvas.err",
	cmd => "/pkg/biology/dotnet/dotnet_v2.1.401_sdk/dotnet /pkg/biology/Canvas/Canvas_v1.38.0/Canvas.dll Somatic-WGS --bam=$path/NV0034-02_S8.mark.sort.bam --somatic-vcf=$path/newsnvs.vcf --sample-b-allele-vcf=$path/b_allele.vcf -r $ref38 -g /project/GP1/jimmy200340/Reference/ref_GRCh38 -n NV0034_canvas -f $path/filter13.bed -o $path/results",
);

#Send Jobs into Queue
$pbs->qsub($canvas);
