while (<>)
{
chomp ($line=$_);
$line=$line."\t"."\t"."\n";
print $line;
}