#!/bin/sh

#SBATCH --account=emm2
#SBATCH --job-name=ANI
#SBATCH --mem=50G
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task 8
#SBATCH --output=data/logs/ANI_DB_prep_%A_%a.out
#SBATCH --error=data/logs/ANI_DB_prep_%A_%a.err
#SBATCH --array=1-2%2


DATA_PATH=data/clean/blastdb

mkdir -p ${DATA_PATH}

TAX=$(ls lists_clean/ | sed 's/_lists.txt//g' | awk "NR == ${SLURM_ARRAY_TASK_ID}") # 2


#Load modules
module load blast
module load python/3.8.5
module load seqkit

#cd ${DATA_PATH};


echo "Processing: ${TAX}"

rm -r data/clean/temp_${TAX}

mkdir -p data/clean/temp_${TAX}


while IFS= read -r SAMPLE; do
	
	echo "  Sample: ${SAMPLE}"

        # Filter sequences longer than 1000 bp
        seqkit seq -m 1000 data/clean/scaffolds_needed/${TAX}_scaffolds/${SAMPLE}*.fasta > data/clean/temp_${TAX}/${SAMPLE}_1k.fasta

        # Split the sequences into 1K-mers with 10 bp overlap
        pyfasta split \
		-k 1000 \
		-o 10 \
		-n 1 \
		data/clean/temp_${TAX}/${SAMPLE}_1k.fasta > data/clean/temp_${TAX}/${SAMPLE}_1k.split.1Kmer.10overlap.fasta

        # Create BLAST database
	makeblastdb \
		-in data/clean/temp_${TAX}/${SAMPLE}_1k.split.1Kmer.10overlap.fasta \
		-dbtype nucl \
		-out ${DATA_PATH}/${SAMPLE}_blastdb/

done < lists_clean/${TAX}_lists.txt

