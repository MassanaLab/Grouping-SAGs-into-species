#!/bin/bash

#SBATCH --job-name=coassm
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=150GB
#SBATCH --output=data/logs/spades_coassemblies_v5_%A_%a.out
#SBATCH --error=data/logs/spades_coassemblies_v5_%A_%a.err
#SBATCH --array=1-3%3

module load spades

SAMPLE=$(cat species_samples_mod5.txt | awk "NR == ${SLURM_ARRAY_TASK_ID}") # 5

OUT_DIR=data/clean/${SAMPLE}_coassembly

mkdir -p ${OUT_DIR}

NUM_THREADS=24

spades.py \
 -s coassemblies_v5_combined_reads/${SAMPLE}_combined_reads.fastq.gz \
 -t ${NUM_THREADS} \
 --sc \
 -k 21,33,55,77,99,127 \
 -o ${OUT_DIR}
