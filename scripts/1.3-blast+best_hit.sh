#!/bin/bash

#SBATCH --time=10:00:00
#SBATCH --job-name=blast
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=1GB
#SBATCH --output=data/logs/blast_%A_%a.out
#SBATCH --error=data/logs/blast_%A_%a.err
#SBATCH --array=1-50%8


module load blast/2.13.0-Linux_x86_64


SAMPLE=$(ls store/0_81_Indv_SAGs_assemblies | awk "NR == ${SLURM_ARRAY_TASK_ID}") # 81


DB_BLAST=lustre/blast_db_alacant+leuven/all_alacant+leuven

RUN_NAME=$(echo ${SAMPLE} | awk -F'/' '{print $NF}')

DB_NAME=$(echo ${DB_BLAST} | awk -F'/' '{print $NF}') # take db name from db

OUT_DIR=lustre/blast_david_alacant+leuven_result

mkdir -p ${OUT_DIR}


THREADS=24


date
echo "Blast sag manual clean ${DB_NAME}"
blastp \
 -query store/0_81_Indv_SAGs_assemblies/${SAMPLE}/${SAMPLE}_aug_aa_hdr.fasta \
 -db ${DB_BLAST} \
 -num_threads ${SLURM_CPUS_PER_TASK} \
 -out ${OUT_DIR}/${SAMPLE}.out \
 -outfmt '6 qseqid sseqid pident length qstart qend sstart send evalue stitle slen qlen' \
 -evalue 1e-150


### Best hit

LC_ALL=C sort \
 -k1,1 -k9,9g \
 ${OUT_DIR}/${SAMPLE}.out | \
 sort -u -k1,1 --merge > ${OUT_DIR}/${SAMPLE}_best_hit.txt

date
echo 'Blast finished'

### Add header
#echo -e "query_id\tsubject_id\t%_identity\taln_len\tq_start\tq_end\ts_start\ts_end\te_value\tseq_title\tseq_len\tq_len" | cat - data/clean/blast_Ill_PAC/blast_results/GC1003827_A03_Ill_PAC.out > data/clean/blast_Ill_PAC/blast_results/GC1003827_A03_Ill_PAC_HDR.out


