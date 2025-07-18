#!/bin/sh

#SBATCH --account=emm2
#SBATCH --job-name=ANI
#SBATCH --cpus-per-task=8
#SBATCH --mem=50G
#SBATCH --ntasks-per-node=1
#SBATCH --output=data/logs/ANIblast_%A_%a.out
#SBATCH --error=data/logs/ANIblast_%A_%a.err
#SBATCH --array=1-2%2
#================================================

#Load modules
module load blast
module load python/3.8.5


TAX=$(ls lists_clean/ | sed 's/_lists.txt//g' | awk "NR == ${SLURM_ARRAY_TASK_ID}") # 2


OUT=data/clean/blast_1to1s/${TAX}

mkdir -p ${OUT}

AR=data/clean/ANI_results/${TAX}_ANI_results

mkdir -p ${AR}


for SAMPLE in $(cat lists_clean/${TAX}_lists.txt)
do

	# Initialize ANI result file for the current sample
	RESULT_FILE="${AR}/ANI_results_${SAMPLE}"
	> ${RESULT_FILE}  # Create or clear the result file for the sample

	for i in $(cat lists_clean/${TAX}_lists.txt); 
	do 
	
		blastn \
			-query data/clean/temp_${TAX}/${i}_1k.split.1Kmer.10overlap.fasta \
			-db data/clean/blastdb/${SAMPLE}_blastdb \
			-outfmt "6 qseqid length pident sseqid qseq sseq" \
			-max_hsps 1 \
			-qcov_hsp_perc 70 \
			-max_target_seqs 1 \
			-evalue 0.00001 \
			-num_threads 8 > ${OUT}/blast_f_sc_${i}_to_${SAMPLE}; 

		h=$(cut -f 2 ${OUT}/blast_f_sc_${i}_to_${SAMPLE} | awk '{s+=$1} END {print s}'); 
	
		p=$(awk ' {print $2*$3/100}' ${OUT}/blast_f_sc_${i}_to_${SAMPLE} | awk '{s+=$1} END {print s/'"$h"'*100}'); 
	
		echo "${OUT}/blast_f_sc_${i}_to_${SAMPLE}  $h  $p" >> ${RESULT_FILE}
	
	done
done
