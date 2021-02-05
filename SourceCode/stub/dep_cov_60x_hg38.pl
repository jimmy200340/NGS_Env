
$GRCh38_main_nonN = 2923732623;
$hg19_nonN        = 2861343702;
#my $ref = $hg19_nonN;
my $ref = $GRCh38_main_nonN;

%depth_coverage=();

$X0  = 0;
$X1  = 0;
$X5  = 0;
$X15 = 0;
$X30 = 0;
$X45 = 0;
$X60 = 0;
$X75 = 0;
$X90 = 0;

while(<>)
{
    chomp(my $line=$_);
    my @tabs = split /\t/,$line;
    if ( $tabs[0] eq "[90<]" ) {
        $depth_coverage->{91} = $tabs[2];
    }
    elsif($tabs[0] eq "[90-90]")
    {
        $depth_coverage->{60} = $tabs[2];
    }
    else { $depth_coverage->{$tabs[1]} = $tabs[2];}
    $X90 = $depth_coverage->{91} + $depth_coverage->{90};
}

$X75 += $X90;
foreach $dep (75..89)
{
    $X75 += $depth_coverage->{$dep};
}

$X60 += $X75;
foreach $dep (60..74)
{
    $X60 += $depth_coverage->{$dep};
}


$X45 += $X60;
foreach $dep (45..59)
{
    $X45 += $depth_coverage->{$dep}; 
}

$X30 += $X45;
foreach $dep (30..44)
{
    $X30 += $depth_coverage->{$dep}; 
}

$X15 += $X30;
foreach $dep (15..29)
{
    $X15 += $depth_coverage->{$dep};
}

$X5 += $X15;
foreach $dep (5..14)
{
    $X5 += $depth_coverage->{$dep};
}

$X1 += $X5;
foreach $dep (1..4)
{
    $X1 += $depth_coverage->{$dep};
}


#$X0 = 3037156770  - $X1;
$X1  = sprintf("%.4f", $X1 /$ref);
$X5 = sprintf("%.4f",  $X5 /$ref);
$X15 = sprintf("%.4f", $X15/$ref);
$X30 = sprintf("%.4f", $X30/$ref);
$X45 = sprintf("%.4f", $X45/$ref);
$X60 = sprintf("%.4f", $X60/$ref);
$X0  = sprintf("%.4f",  1-$X1   );  

print ">=1X\t>=5X\t>=15X\t>=30X\t>=45X\t>=60X\t>=75X\t>=90X\n";
print "$X1\t$X5\t$X15\t$X30\t$X45\t$X60\t$X75\t$X90\n";
#print $X0."\n";




