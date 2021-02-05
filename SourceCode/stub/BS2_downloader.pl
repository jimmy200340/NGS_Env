my $appsession = "";
my $dataset = 'result';
my @id = "";
my $serial = 1;

print "Please enter Session ID : ";
chomp($appsession=<STDIN>);
system ("bs2 appsession property get -i $appsession --property-name=\"output.datasets\" > ./dataset");
system ("grep -o 'ds.*' ./dataset |awk '{print substr (\$0,0,35)}' > ./result");

open (DATA,">Download_Fastq.sh") || die "Can't open file";

@id = get_file_data ($dataset);
foreach $id (@id)
{
	chomp $id;
	print DATA "bs2 download dataset --id $id -o ./$serial;\n";
	$serial ++;
}

sub get_file_data
{
	my($filename) = @_;
	
	use strict;
	use warnings;
	my @filedata = ();
	
		unless( open(GET_FILE_DATA, $filename) )
		{
			print STDERR "Can't open file \"$filename\"\n\n";
			exit;
		}
		
	@filedata = <GET_FILE_DATA>;
	close GET_FILE_DATA;
	return @filedata;
}