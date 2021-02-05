my $run = "190717_A00321_0035_AHM7NMDSXX";
my $path = "/home/jimmy200340";
chdir ("$path");
open (DATA, ">mail.txt") || die "cannot open file";
my $subject = "FastQC_upload_notice";
my $mail = "tsaich\@tgiainc.com";

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
print DATA "$run";
print DATA "$content2";

system ("mail -s $subject -r 061012\@nhri.edu.tw $mail < $path/mail.txt");