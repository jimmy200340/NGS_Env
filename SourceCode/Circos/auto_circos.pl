#include module
use Getopt::Long;

my $folder = "";
my $target = "##FASTA";
my $last_line = "";
my $CDS = "";
my $gcdata = "~/bin/gcdata";
my $circos = "/home/jimmy200340/opt/circos-0.69-9/bin/circos";
my @highlight = "";
#define custom parameter(s)
GetOptions
(
	'folder=s' => \$folder,
);

#print usage and exit if lack of required parameters
if ($folder eq "")
{
	usage();
	exit;
}

#Create folder structure
mkdir "$folder/08.genome_map";
mkdir "$folder/08.genome_map/data";
mkdir "$folder/08.genome_map/etc";

###fa to circos gc data
$fasta = `ls $folder/02.gene_prediction/Chromosome/ | grep fna`;
chomp $fasta;
system ("python $gcdata -f $folder/02.gene_prediction/Chromosome/$fasta > $folder/08.genome_map/gc_data.txt");

open (GCDATA, "<$folder/08.genome_map/gc_data.txt") || die "Can't open file";
chomp (my @line = <GCDATA>);
my $sum = scalar @line;
open (CONTENT, ">$folder/08.genome_map/data/gc_content.txt") || die "Can't create file";
open (SKEW, ">$folder/08.genome_map/data/gc_skew.txt") || die "Can't create file";

LOOP:
for (0..$sum-1)
{
	my $content = @line[$_];
	my @content = split(' ',$content);
	print CONTENT "chr1 @content[1] ";
	print CONTENT "@content[2] ";
	print CONTENT "@content[3]";
	print CONTENT "\n";
	
	print SKEW "chr1 @content[1] ";
	print SKEW "@content[2] ";
	print SKEW "@content[4]";
	print SKEW "\n";

}
close GCDATA;
close CONTENT;
close SKEW;

###gff to circos data
$gff = `ls $folder/02.gene_prediction/Chromosome/ | grep gff`;
chomp $gff;
open (CHR, "<$folder/02.gene_prediction/Chromosome/$gff") || die "Can't open file";

chomp (my @line = <CHR>);
my $sum = scalar @line;

#Prepare karyotype
LOOP:
for (0..$sum)
{
	if ($line[$_] eq $target)
	{
		$last_line = $_ - 1;
		last LOOP;
	}
}

$linechr = @line[1];
my @linechr = split(' ',$linechr);

open (DATA,">$folder/08.genome_map/data/karyotype.txt") || die "Can't create file";
print DATA "chr - chr1 1 0 ";
print DATA "@linechr[3] yellow";
print DATA "\n";
close DATA;

=pod
open (DATA,">gene.txt") || die "Can't create file";
LOOP:
for (2..$last_line)
{
	$band = @line[$_];
	my @band = split(' ',$band);
	
	if ($band[2] eq gene)
	{
		print DATA "chr1 ";
		print DATA "@band[3] ";
		print DATA "@band[4] ";
		print DATA "gene";
		print DATA "\n";
	}	
}
close DATA;
=cut

#prepare dnaA label
open (LABEL,">$folder/08.genome_map/data/label.txt") || die "Can't create file";
LOOP:
for (2..$last_line)
{
	$band = @line[$_];
	my @band = split(' ',$band);	
	if ($band[2] eq gene)
	{
		my $id = @band[8];
		my @name = split(';',$id);
		my @dnaA = split('=',@name[1]);
		if (@dnaA[1] eq dnaA)
		{
			print LABEL "chr1 ";
			print LABEL "@band[3] ";
			print LABEL "@band[4] ";
			print LABEL "@dnaA[1] ";
			print LABEL "\n";
		}
	}	
}
close LABEL;

#prepare CDS
open (CDS_P,">$folder/08.genome_map/data/CDS_P.txt") || die "Can't create file";
open (CDS_N,">$folder/08.genome_map/data/CDS_N.txt") || die "Can't create file";
push (@highlight ,("$folder/08.genome_map/data/CDS_P.txt"));
push (@highlight ,("$folder/08.genome_map/data/CDS_N.txt"));
LOOP:
for (2..$last_line)
{
	$band = @line[$_];
	my @band = split(' ',$band);
	
	if ($band[2] eq CDS)
	{
			if ($band[6] eq '+')
			{
				print CDS_P "chr1 ";
				print CDS_P "@band[3] ";
				print CDS_P "@band[4] ";
				print CDS_P 'CDS';
				print CDS_P "\n";
			}
			else
			{
				print CDS_N "chr1 ";
				print CDS_N "@band[3] ";
				print CDS_N "@band[4] ";
				print CDS_N 'CDS';
				print CDS_N "\n";
			}
	}	
}
close CDS_P;
close CDS_N;

#prepare rRNA
open (DATA,">$folder/08.genome_map/data/rRNA.txt") || die "Can't create file";
push (@highlight ,("$folder/08.genome_map/data/rRNA.txt"));
LOOP:
for (2..$last_line)
{
	$band = @line[$_];
	my @band = split(' ',$band);
	
	if ($band[2] eq rRNA)
	{
		print DATA "chr1 ";
		print DATA "@band[3] ";
		print DATA "@band[4] ";
		print DATA "optgreen";
		print DATA "\n";
	}
}
close DATA;

#prepare tRNA
open (DATA,">$folder/08.genome_map/data/tRNA.txt") || die "Can't create file";
push (@highlight ,("$folder/08.genome_map/data/tRNA.txt"));
LOOP:
for (2..$last_line)
{
	$band = @line[$_];
	my @band = split(' ',$band);
	
	if ($band[2] eq tRNA)
	{
		print DATA "chr1 ";
		print DATA "@band[3] ";
		print DATA "@band[4] ";
		print DATA 'tRNA';
		print DATA "\n";
	}	
}
close DATA;

#create config file and draw the map
highlight_conf();
tick_conf();
circos_conf();
circos();

sub usage
{
	print "\n";
	print "Fatal error : PLEASE SPECIFY TARGET PATH !!!\n\n";
	print "#####################################\n";
	print "# Auto Circos for Small Genome v1.0 #\n";
	print "#####################################\n\n";
	print "Usage: perl gff2circos.pl --folder PATH\n\n";
	print "--folder		Path to target folder";
	print "\n\n";
}

sub highlight_conf
{
	open (HIGHLIGHT,">$folder/08.genome_map/etc/highlights.conf") || die "Can't create file";
	$i = "0.99";
	$j = "0.94";
	$k = 1;
	$l = 0;
	@color = ("116,201,240","232,56,123","61,169,161","93,209,203");
	
	print HIGHLIGHT "<highlights>\n";
	shift @highlight;
	foreach $highligh(@highlight)
	{
		chomp $highligh;
		print HIGHLIGHT "\n<highlight>\n";
		print HIGHLIGHT "file = $highligh\n";
		print HIGHLIGHT "fill_color = @color[$l]\n";
		$k++;
		$l++;
		print HIGHLIGHT "r1 = $i";
		print HIGHLIGHT "r\n";
		$i = $i - 0.06;
		print HIGHLIGHT "r0 = $j";
		print HIGHLIGHT "r\n";
		$j = $j - 0.06;
		print HIGHLIGHT "</highlight>\n";
	}
	print HIGHLIGHT "</highlights>\n";
	
}

sub tick_conf
{
	open (TICK,">$folder/08.genome_map/etc/ticks.conf") || die "Can't create file"; 
	$tick = <<EOF;
show_ticks = yes
show_tick_labels = yes

<ticks>
radius = dims(ideogram,radius_outer)
multiplier = 1e-6
label_offset = 5p
thickness = 3p
size = 20p
label_separation = 5p

<tick>
spacing = 0.5u
color = red
show_label = yes
label_size = 50p
label_font = bold
label_offset = 0p
format = %.1f
</tick>

<tick>
spacing = 1u
color = red
show_label = yes
label_size = 50p
label_font = bold
label_offset = 0p
format = %d
</tick>

<tick>
spacing = 0.1u
color = black
show_label = yes
label_size = 20p
label_font = bold
label_offset = 0p
format = %.1f
</tick>
</ticks>
EOF
	
	print TICK "$tick";
}

sub circos_conf
{
	open (CIRCOS,">$folder/08.genome_map/etc/circos.conf") || die "Can't create file";
	open (CONF,"</home/jimmy200340/opt/circos-0.69-9/circos.conf");
	chomp (my @line = <CONF>);
	$num = scalar @line;
	print CIRCOS "# circos.conf\n";
	print CIRCOS "karyotype = $folder/08.genome_map/data/karyotype.txt\n";
	for (2..29)
	{
		print CIRCOS @line[$_];
		print CIRCOS "\n";
	}
	print CIRCOS "file = $folder/08.genome_map/data/gc_content.txt\n";
	for (31..42)
	{
		print CIRCOS @line[$_];
		print CIRCOS "\n";		
	}
	print CIRCOS "file = $folder/08.genome_map/data/gc_skew.txt\n";
	for (44..67)
	{
		print CIRCOS @line[$_];
		print CIRCOS "\n";		
	}
	print CIRCOS "file = $folder/08.genome_map/data/label.txt\n";
	for (69..94)
	{
		print CIRCOS @line[$_];
		print CIRCOS "\n";		
	}
	print CIRCOS "<<include $folder/08.genome_map/etc/highlights.conf>>\n";
	print CIRCOS "<<include $folder/08.genome_map/etc/ticks.conf>>\n";
	close CIRCOS;
	close CONF;
}

sub circos
{
	system ("$circos --noparanoid --conf $folder/08.genome_map/etc/circos.conf");
	system ("mv circos.png $folder/08.genome_map/");
	system ("mv circos.svg $folder/08.genome_map/");
	system ("rm -r $folder/08.genome_map/etc");
}