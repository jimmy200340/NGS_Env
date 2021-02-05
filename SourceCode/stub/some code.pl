#Aspera
system ("ascp -k1 -R /local/Jimmy200340/aspera_log/ $source jimmy200340@140.110.141.75:/novaseq/");

#kill all jobs
qstat | grep jimmy200340 | cut -d"." -f1 | xargs qdel

#set ACL
setfacl -R -m u:u00ccl01:rwx flagship

#basemount
cd ~;
basemount --unmount basespace;
basemount --api-server http://nhri.api.basespace.illumina.com/ --cache-opts 4:32:1024 --threads 16 basespace;

#s3fs
s3fs novaseq /work2/jimmy200340/NovaSeq_S3/ -o passwd_file=~/.passwd-s3fs -o url=http://s3-cloud.nchc.org.tw -o uid=10265,gid=3530 -o use_path_request_style
 
 bsub -q 128G -e vep.err -o vep.out -J vep "source /pkg/biology/Ensembl_VEP/Ensembl_VEP_v91/env.sh && /pkg/biology/Ensembl_VEP/Ensembl_VEP_v91/vep --fork 40 --offline --assembly GRCh37 --plugin dbNSFP,/pkg/biology/Ensembl_VEP/Ensembl_VEP_v91/dbNSFP3.5a.txt.gz -i variants.vcf.gz"

#ascp exclude
ascp -E '*.png'