#!/usr/bin/perl

$start=$ARGV[0];
$end=$ARGV[1];
print $start."\n";
print $end."\n";

for(my $i=$start;$i<=$end;$i++){
	print $i."\n";
	`qdel $i`;
}

