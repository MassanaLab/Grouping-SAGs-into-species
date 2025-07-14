# BLAST

## Selection from BLAST results

# ANI

# Concatenate reads from selected samples

### 0.1 - Prepare reads

Start by putting in a folder all the reads from the different SAGs you want to assembly toghether.

### 0.2 -  Prepare lists

Make a .txt file containing all the names of needed individual SAGs that will form each coassembly. Make one .txt file per coassembly, and name this file like x_lists.txt. Ideally, put all this lists in a folder.

### 1 - Combine reads

```
OUT=lustre/coassemblies_v5_combined_reads

rm -r ${OUT}

mkdir -p ${OUT}


n1=0
n2=$(ls lustre/coass_v5_lists_clean/ | wc -l)


for FILE in $(ls lustre/coass_v5_lists_clean/)
do

        n1=$((n1 + 1))

        FN=$(echo $FILE | awk -F "_" '{print $1"_"$2"_"$3}' | sed 's/.txt//g')

        echo "Combining ${FN} (${n1} of ${n2} taxa):"

        for SAMPLE in $(cat lustre/coass_v5_lists_clean/${FILE})
        do
          	echo "Adding ${SAMPLE}..."
                cat store/reads_P_AH_GC/${SAMPLE}* >> ${OUT}/${FN}_combined_reads.fastq.gz

        done

done
```

### 2 - SPAdes Assebmly

```
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
```

### 3 - Quast, BUSCO, Tiara

Explained in the [QBT-pipeline](https://github.com/MassanaLab/QBT-pipeline).

All steps after QBT are explained [here](https://github.com/MassanaLab/SAGs-pipeline?tab=readme-ov-file#braker), starting with BRAKER.
