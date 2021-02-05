#set variables
my @run = ("190717_A00321_0035_AHM7NMDSXX");
my $path = "/work2/jimmy200340/NovaSeq/".$run;

#create mail file
chdir ("$path");
open (DATA, ">mail.txt") || die "cannot open file";

#set mail subject
my $subject = "FastQC_upload_notice";

#set mail list
#my $mail = "olga200340\@nhri.org.tw";
my $mail = "olga200340\@nhri.org.tw hklin66\@gmail.com meo20113\@gmail.com tsaich\@tgiainc.com justgreenthought\@nhri.edu.tw TYLIN\@nhri.edu.tw hctu0915\@nhri.edu.tw iffive\@gmail.com huameichang68\@gmail.com tsailien\@nhri.org.tw ttliu\@ym.edu.tw ymliu\@nhri.org.tw cclai\@nhri.org.tw";

#set mail content
$content = <<EOF;
Dear All,

EOF
$content2 = <<EOF;
 FastQC report has been uploaded, Please check.

http://pm.nhri.org.tw/NovaSeq/

========================================== 
國家衛生研究院
分子與基因醫學研究所 李義安
Yi-An Li
Research Associate
Institute of Molecular and Genomic Medicine, NHRI
Tel : 037-246166 #35330
Cell : 0986276258
olga200340\@nhri.edu.tw
==========================================

EOF

print DATA "$content";
print DATA "@run";
print DATA "$content2";

#upload file
foreach $run (@run)
	{
	system ("cd $path ; scp -r Data/Intensities/BaseCalls/Reports/ pm.nhri.edu.tw:/var/www/html/NovaSeq/runFolders/$run/ ; scp -r Data/Intensities/BaseCalls/Stats/ pm.nhri.edu.tw:/var/www/html/NovaSeq/runFolders/$run/ ; scp -r Unalign/_fastqc/*_fastqc pm.nhri.edu.tw:/var/www/html/NovaSeq/runFolders/$run/_fastqc/ ; rsync -avhs --exclude='fastp/*.json' --exclude='fastp/log' Unalign/fastp pm.nhri.edu.tw:/var/www/html/NovaSeq/runFolders/$run/");
	}
#send mail
system ("mail -s $subject -r 061012\@nhri.edu.tw $mail < $path/mail.txt ; rm $path/mail.txt");


