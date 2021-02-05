
$GRCh38_main_nonN = 2923732623;
$hg19_nonN        = 2861343702;
my $ref = $hg19_nonN;

%depth_coverage=();

$X0  = 0;
$X1  = 0;
$X10 = 0;
$X20 = 0;
$X30 = 0;
$X40 = 0;
$X50 = 0;
$X60 = 0;

while(<>)
{
    chomp(my $line=$_);
    my @tabs = split /\t/,$line;
    if ( $tabs[0] eq "[60<]" ) {
        $depth_coverage->{61} = $tabs[2];
    }
    elsif($tabs[0] eq "[60-60]")
    {
        $depth_coverage->{60} = $tabs[2];
    }
    else { $depth_coverage->{$tabs[1]} = $tabs[2];}
    $X60 = $depth_coverage->{61} + $depth_coverage->{60};
}

$X50 += $X60;

foreach $dep (50..59)
{
    $X50 += $depth_coverage->{$dep}; 
}

$X40 += $X50;
foreach $dep (40..49)
{
    $X40 += $depth_coverage->{$dep}; 
}

$X30 += $X40;
foreach $dep (30..39)
{
    $X30 += $depth_coverage->{$dep};
}

$X20 += $X30;
foreach $dep (20..29)
{
    $X20 += $depth_coverage->{$dep};
}

$X10 += $X20;
foreach $dep (10..19)
{
    $X10 += $depth_coverage->{$dep};
}

$X1 += $X10;
foreach $dep (1..9)
{
    $X1 += $depth_coverage->{$dep};
}

#$X0 = 3037156770  - $X1;
$X1  = sprintf("%.4f", $X1 /$ref);
$X10 = sprintf("%.4f", $X10/$ref);
$X20 = sprintf("%.4f", $X20/$ref);
$X30 = sprintf("%.4f", $X30/$ref);
$X40 = sprintf("%.4f", $X40/$ref);
$X50 = sprintf("%.4f", $X50/$ref);
$X60 = sprintf("%.4f", $X60/$ref);
$X0  = sprintf("%.4f",  1-$X1   );  

print "0\t>=1X\t>=10X\t>=20X\t>=30X\t>=40X\t>=50X\t>=60X\n";
print "$X0\t$X1\t$X10\t$X20\t$X30\t$X40\t$X50\t$X60\n";
#print $X0."\n";




