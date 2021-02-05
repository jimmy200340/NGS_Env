bsub -q 128G -e vep.err -o vep.out -J vep "source /pkg/biology/Ensembl_VEP/Ensembl_VEP_v91/env.sh && /pkg/biology/Ensembl_VEP/Ensembl_VEP_v91/vep --fork 40 --offline --assembly GRCh37 --plugin dbNSFP,/pkg/biology/Ensembl_VEP/Ensembl_VEP_v91/dbNSFP3.5a.txt.gz -i variants.vcf.gz"

