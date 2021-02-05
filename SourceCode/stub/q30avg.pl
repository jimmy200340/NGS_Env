#!/pkg/biology/Perl/Perl_v5.28.0/bin/perl

#use PBS::Client;
%q30=();

while(<>)
{
	chomp(my $line=$_);
	my @tabs = split /\t/,$line;
		if (!(exists $q30 -> {$tabs[2]}))
			{
			$q30 -> {$tabs[2]} -> {"yield"} = 0;
			$q30 -> {$tabs[2]} -> {"q30"} = 0;
			}
		$q30 -> {$tabs[2]} -> {"yield"} += $tabs[8];
		$q30 -> {$tabs[2]} -> {"q30"} += $tabs[8]*$tabs[10];
		#print "$tabs[8]\n";
}

foreach my $sample_id (keys %{$q30})
{
	#print "$sample_id\n";
	$q30 -> {$sample_id} -> {"q30avg"} = $q30 -> {$sample_id} -> {"q30"} / $q30 -> {$sample_id} -> {"yield"};
	$yield = $q30 -> {$sample_id} -> {"yield"};
	$q30avg = $q30 -> {$sample_id} -> {"q30avg"};
	print "$sample_id\t$yield\t$q30avg\n";
}