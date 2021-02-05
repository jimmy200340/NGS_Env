#!/pkg/biology/Perl/Perl_v5.28.0/bin/perl

$GRCh38_main_nonN = 2923732623;
$hg19_nonN        = 2861343702;
$CRE_V2_hg38      = 67350516;
#my $ref = $hg19_nonN;
my $ref = $CRE_V2_hg38;

%depth_coverage=();

$X0  = 0;
$X1  = 0;
$X50 = 0;
$X100 = 0;
$X150 = 0;
$X200 = 0;
$X250 = 0;
$X300 = 0;
$X350 = 0;
$X400 = 0;
$X450 = 0;
$X500 = 0;
$X550 = 0;
$X600 = 0;

while(<>)
{
    chomp(my $line=$_);
    my @tabs = split /\t/,$line;
    if ( $tabs[0] eq "[600<]" ) {
        $depth_coverage->{601} = $tabs[2];
    }
    elsif($tabs[0] eq "[551-600]")
    {
        $depth_coverage->{600} = $tabs[2];
    }
    else { $depth_coverage->{$tabs[1]} = $tabs[2];}
}

$X600 += $depth_coverage->{601};

$X550 += $X600;
$X550 += $depth_coverage->{600}; 

$X500 += $X550;
$X500 += $depth_coverage->{550};

$X450 += $X500;
$X450 += $depth_coverage->{500};

$X400 += $X450;
$X400 += $depth_coverage->{450};

$X350 += $X400;
$X350 += $depth_coverage->{400};

$X300 += $X350;
$X300 += $depth_coverage->{350};

$X250 += $X300;
$X250 += $depth_coverage->{300};

$X200 += $X250;
$X200 += $depth_coverage->{250};

$X150 += $X200;
$X150 += $depth_coverage->{200};

$X100 += $X150;
$X100 += $depth_coverage->{150};

$X50  += $X100;
$X50  += $depth_coverage->{100};

$X1   += $X50;
$X1   += $depth_coverage->{50};

if($X1 > $ref) { $ref=$X1; }

$X1  =  sprintf("%.4f", $X1   /$ref);
$X50 =  sprintf("%.4f", $X50  /$ref);
$X100 = sprintf("%.4f", $X100 /$ref);
$X150 = sprintf("%.4f", $X150 /$ref);
$X200 = sprintf("%.4f", $X200 /$ref);
$X250 = sprintf("%.4f", $X250 /$ref);
$X300 = sprintf("%.4f", $X300 /$ref);
$X350 = sprintf("%.4f", $X350 /$ref);
$X400 = sprintf("%.4f", $X400 /$ref);
$X450 = sprintf("%.4f", $X450 /$ref);
$X500 = sprintf("%.4f", $X500 /$ref);
$X550 = sprintf("%.4f", $X550 /$ref);
$X600 = sprintf("%.4f", $X600 /$ref);

$X0  = sprintf("%.4f",  1-$X1   );  

print "0\t>=1X\t>50X\t>100X\t>150X\t>200X\t>250X\t>300X\t>350X\t>400X\t>450X\t>500X\t>550X\t>600X\n";
print "$X0\t$X1\t$X50\t$X100\t$X150\t$X200\t$X250\t$X300\t$X350\t$X400\t$X450\t$X500\t$X550\t$X600\n";




