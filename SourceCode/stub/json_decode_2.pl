#!/pkg/biology/Perl/Perl_default/bin/perl
use strict;
use JSON;
use Template;

my @inputs = @ARGV;

my $template=Template->new({PRE_CHOMP => 1});
my @rows = ();
my $sid_name_yield;
my $region = 3000; 

#<tr><th>Sample ID</th><th>Total reads</th><th>Total bases</th><th>Q20 rate</th><th>Q30 rate</th><th>Read1 mean length</th><th>Read2 mean length</th><th>Expected yields (Mbases)</th><th>Deduplication rate</th><th>Estimate coverage</th><th>Estimate coverage (Dedup) </th> <th> Expected yields - Total bases (Mbases) </th> </tr>

my $flag=1;
open (FH, "<$inputs[0]");
while(<FH>)
{
 chomp (my $line = $_);
 my @commas = split /,/, $line;
 $sid_name_yield->{$flag}->{"id"}       = $commas[2];
 $sid_name_yield->{$flag}->{"name"}     = $commas[0];
 $sid_name_yield->{$flag}->{"coverage"} = $commas[1];
 $sid_name_yield->{$flag}->{"region"}   = $region;
  
 if ($commas[1] =~ /(\d+\.?\d?)X WGS/)
 {
  my $out = $1;
  $region = 3000;
  $sid_name_yield->{$flag}->{"region"}  = $region;
  $sid_name_yield->{$flag}->{"yield"}   = $out * $region;
 }
 elsif ($commas[1] =~ /(\d+\.?\d?)X (WMS|WES)\((\d+\.?\d?)(G|M)\)/)
 {
  (my $out, my $type, my $yield, my $scale)= ($1, $2, $3, $4);
  
  #$region = 67.3;
  if ($scale eq "G")
  {
   $region = $yield * 1000 / $out;
  }
  elsif ($scale eq "M")
  {
   $region = $yield / $out;
  }
  $sid_name_yield->{$flag}->{"coverage"} = $out."X $type";
  $sid_name_yield->{$flag}->{"region"}   = $region;
  $sid_name_yield->{$flag}->{"yield"}    = $region * $out;
 }
 #elsif ($commas[1] =~ /(\d+\.?\d?)(G|M)/)
 #{
 # my $out   = $1;
 # my $scale = $2;
 # if ($scale eq "G")
 # {
 #  $region = $out * 1000;
 # }
 # elsif ($scale eq "M") 
 # {
 #  $region = $out;
 # }
 # $sid_name_yield->{$flag}->{"region"}  = $region;
 # $sid_name_yield->{$flag}->{"yield"}   = $region;
 #}
 $flag++;
}


foreach my $id ( sort { $a <=> $b } (keys %{$sid_name_yield}))
{
 my $sid     = $sid_name_yield->{$id}->{"id"};
 my $sname   = $sid_name_yield->{$id}->{"name"};
 my $sample  = $sid."_n_".$sname;
 my $sid_url = "<a href=\"./$sample.fastp.html\"> $sid </a>";

open (han1, "$sample.fastp.json") or die "can not read this file: $!\n";
my $json_string = join '', <han1>;
my $json_data = decode_json $json_string;
close (han1);

#$output_string .= "$sample\t".$json_data->{"summary"}->{"before_filtering"}->{"total_reads"}."\t";
my $total_read = $json_data->{"summary"}->{"before_filtering"}->{"total_reads"};
my $total_read_f = commify($total_read);
#$output_string .= $json_data->{"summary"}->{"before_filtering"}->{"total_bases"}."\t";
my $total_bases = $json_data->{"summary"}->{"before_filtering"}->{"total_bases"};
my $total_bases_f = commify($total_bases);
#$output_string .= $json_data->{"summary"}->{"before_filtering"}->{"q20_rate"}."\t";
my $q20_rate = $json_data->{"summary"}->{"before_filtering"}->{"q20_rate"};
my $q20_rate_f = sprintf("%.2f", $q20_rate*100)."%";
#$output_string .= $json_data->{"summary"}->{"before_filtering"}->{"q30_rate"}."\t";
my $q30_rate = $json_data->{"summary"}->{"before_filtering"}->{"q30_rate"};
my $q30_rate_f = sprintf("%.2f", $q30_rate*100)."%";
#$output_string .= $json_data->{"summary"}->{"before_filtering"}->{"read1_mean_length"}."\t";
my $r1_len = $json_data->{"summary"}->{"before_filtering"}->{"read1_mean_length"};
#$output_string .= $json_data->{"summary"}->{"before_filtering"}->{"read2_mean_length"}."\t";
my $r2_len =  $json_data->{"summary"}->{"before_filtering"}->{"read2_mean_length"};
#my $read_len = $total_bases / $total_read;
my $e_coverage = $sid_name_yield->{$id}->{"coverage"};
my $e_yield    = $sid_name_yield->{$id}->{"yield"}; 
my $e_yield_f  = commify($e_yield);
my $e_y_cov    = $e_yield_f." ( $e_coverage )";
my $dedup = 1 - $json_data->{"duplication"}->{"rate"}; 
my $dedup_f = sprintf("%.2f", $dedup*100)."%";
my $region_each = $sid_name_yield->{$id}->{"region"};
my $cov_1 = $total_bases * $dedup  / ($region_each * 1000000);
my $cov_1_f = sprintf("%.2f", $cov_1); 
my $cov_2 = $total_bases / ($region_each * 1000000); 
my $cov_2_f = sprintf("%.2f", $cov_2);

my $diff_1  = (($total_bases / 1000000) - $e_yield ) / $region_each;
my $diff_1_f = sprintf("%.2f", $diff_1);
my $diff_2  = (($total_bases * $dedup / 1000000) - $e_yield ) / $region_each;
my $diff_2_f = sprintf("%.2f", $diff_2);
#$output_string .= "$dedup\t$cov_1\n";
push @rows,[$sid_url,$sname,$total_read_f,$total_bases_f,$q20_rate_f,$q30_rate_f,$r1_len,$r2_len,$e_y_cov,$dedup_f,$cov_2_f,$cov_1_f,$diff_1_f,$diff_2_f];
}

$template->process("table.tmpl",{rows => \@rows}) || die $template->error();

sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    return scalar reverse $text;
}
