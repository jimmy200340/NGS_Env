#!/pkg/biology/Perl/Perl_v5.28.0/bin/perl

#Modules to use
use strict;
use PBS::Client;

#Project id
#107119

#Executable path
my $bwa = "~/bin/bwa";
my $samtools = "~/bin/samtools";
my $samblaster = "~/bin/samblaster";
my $sambamba = "~/bin/sambamba";
my $bcl2fastq = "~/bin/bcl2fastq";
my $fastqc = "~/bin/fastqc";
my $fastp = "~/bin/fastp";

my $run = "190711_A00322_0054_AHM7JYDSXX";
my $path = "/work2/jimmy200340/".$run;
my $core = 10;
my $mem = "45gb";

system ("cd $path/Unalign ; mkdir fastp ; mkdir fastp/log");
system("dos2unix $path/SampleSheet.csv");
open (SS, "<$path/SampleSheet.csv");

#Lane Usage ("1" => "1" , "2" => "1" , "3" => "1" , "4" => "1")
#my %lane= ("1" => "1");
my %lane= ("1" => "1" , "2" => "1" , "3" => "1" , "4" => "1");
my $flag = 0;
my $SampleSheetData;
my $SampleID_Des;
my $seq_mode;
my @cols;

while (<SS>)
{
 chomp (my $line = $_ );

 if ($flag == 0)
 {
  if ($line =~ /^\[Data/)
  {
   $flag++;
  }
 }
 elsif ($flag == 1)
 {
  @cols = split /,/, $line;
  #print $cols[-1]."\n";
  if ($cols[0] eq "Lane")
  { $seq_mode = "XP"; }
  else { $seq_mode = "Regular"; }
  
  $flag++;
 }
 else
 {
  my @tabs = split /,/, $line;

  for (my $i=0; $i <= $#cols; $i++)
  {
   $SampleSheetData->{$flag}->{$cols[$i]} = $tabs[$i];
   #print "$flag\t".$cols[$i]."\t".$tabs[$i]."\n";
  }
   #print $cols[-1]."\t".$SampleSheetData->{$flag}->{$cols[-1]}."\n";
  $flag ++;
 }
 
} 

close(SS);
 
foreach my $d ( keys %{$SampleSheetData})
{
 my $S_ID   = $SampleSheetData->{$d}->{"Sample_ID"};
 my $S_Name = $SampleSheetData->{$d}->{"Sample_Name"};
 my $S_Des  = $SampleSheetData->{$d}->{"Description"};
 my $S_Lane = 5;
 #print "$d\t$S_ID\t$S_Name\t$S_Des\n";
 if ($seq_mode eq "XP")
 {
  $S_Lane = $SampleSheetData->{$d}->{"Lane"};
 }
 
 
 if ( ($S_ID eq $S_Name) && ($S_Lane == 5 || $lane{$S_Lane} == 1))
 {
  $SampleID_Des -> {$S_ID} -> {"Name"} = $S_Des;
  #print $S_ID."\t".$S_Des."\n";
 }
}

my $pbs = PBS::Client->new();


foreach my $id (keys %{$SampleID_Des})
{
  my $S_name  = $SampleID_Des -> {$id} -> {"Name"};
  my $id_name = $id."_n_".$S_name;
  
  # merge and rename the fastq files in Unalign folder
  my $merge = PBS::Client::Job->new
   (
        queue => 'nhri192G',
        name => "$id.merge",
        project => "MST107119",
        group => "MST107119",
		select => "1",
        mem => $mem,
        ncpus => $core,
        ofile => "$id.merge.std",
        efile => "$id.merge.err",
        cmd => "cd $path/Unalign; cat $id\_S*_R1_001.fastq.gz > $S_name\_R1_001.fastq.gz; cat $id\_S*_R2_001.fastq.gz > $S_name\_R2_001.fastq.gz; rm $id\_S*_R1_001.fastq.gz $id\_S*_R2_001.fastq.gz",
   );
   
   # use fastp to do QC for fastQ files
   my $all_fastp = PBS::Client::Job->new
   (
        queue => 'nhri192G',
        name => "$id.fastp",
        project => "MST107119",
        group => "MST107119",
		select => "1",
        mem => $mem,
        ncpus => $core,
        ofile => "$id.fastp.std",
        efile => "$id.fastp.err",
        cmd => "cd $path/Unalign; $fastp -w $core -i $S_name\_R1_001.fastq.gz -I $S_name\_R1_001.fastq.gz -j ./fastp/$id_name.fastp.json -h ./fastp/$id_name.fastp.html",
   );
   
	#movelog
	my $mvlog = PBS::Client::Job->new
	(
		queue => 'nhri192G',
		name => "$id.mvlog",
		project => "MST107119",
		group => "MST107119",
		select => "1",
        mem => $mem,
        ncpus => $core,
		cmd => "cd $path ; mv $path/*.std $path/Unalign/fastp/log/ ; mv $path/*.err $path/Unalign/fastp/log/ ; rm $path/pbsjob* ; rm $path/*mvlog*",
	);
   
   #Set Job Dependency
   
   $merge->next({ok => $all_fastp});
   $all_fastp->next({ok => $mvlog});
   
   #Send Jobs into Queue
   
   $pbs->qsub($merge);
   
}


 
