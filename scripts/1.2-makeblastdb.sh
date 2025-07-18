#!/bin/bash

#SBATCH --time=02:00:00
#SBATCH --job-name=makeblastdb
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=2GB
#SBATCH --output=data/logs/makeblastdb_%A_%a.out
#SBATCH --error=data/logs/makeblastdb_%A_%a.err

OUT=lustre/blast_db_alacant+leuven/

mkdir -p ${OUT}

module load blast/2.13.0-Linux_x86_64

makeblastdb -in store/all_alacant+leuven.aa -dbtype prot -parse_seqids -out ${OUT}/all_alacant+leuven
