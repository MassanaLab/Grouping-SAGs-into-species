# Coassemblies

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

### 3 - Seqkit filter 1000

```
module load seqkit

OUT=lustre/coassemblies_v5_filter1000

rm -r ${OUT}

mkdir -p ${OUT}

for SCAFF in $(ls lustre/spades_coassembly_v5/ | awk -F '.' '{print $1}')
do

        seqkit seq -m 1000 lustre/spades_coassembly_v5/${SCAFF}.fasta -o ${OUT}/${SCAFF}_filter1000.fasta

done
```

### 4 - Quast, BUSCO, Tiara (filter 1000)

```
#!/bin/bash

#SBATCH --time=00:30:00
#SBATCH --job-name=qbt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=18
#SBATCH --mem=5GB
#SBATCH --output=data/logs/qbt_coass_v5_%A_%a.out
#SBATCH --error=data/logs/qbt_coass_v5_%A_%a.err
#SBATCH --array=1-3%3

SAMPLE=$(ls lustre/spades_coassembly_v5/ | awk -F "_" '{print $1"_"$2"_"$3}' | awk "NR == ${SLURM_ARRAY_TASK_ID}") # 3

#####################################

mkdir -p ~/lustre/qbt_coassembly_filter1000_v5/quast/

~/store/quast/metaquast.py \
 --contig-thresholds 0,1000,3000,5000 \
 -o ~/lustre/qbt_coassembly_filter1000_v5/quast/${SAMPLE} \
 ~/lustre/coassemblies_v5_filter1000/${SAMPLE}_coassembly_scaffolds_filter1000.fasta

#####################################

module load cesga/2020

mkdir -p ~/lustre/qbt_coassembly_filter1000_v5/tiara/

~/.local/bin/tiara \
 -i ~/lustre/coassemblies_v5_filter1000/${SAMPLE}_coassembly_scaffolds_filter1000.fasta \
 -o ~/lustre/qbt_coassembly_filter1000_v5/tiara/${SAMPLE}

#####################################

module load gcc/system busco/5.3.2

mkdir -p ~/lustre/qbt_coassembly_filter1000_v5/busco/

BUSCO_db=eukaryota_odb10

busco \
 --in ~/lustre/coassemblies_v5_filter1000/${SAMPLE}_coassembly_scaffolds_filter1000.fasta \
 -o lustre/qbt_coassembly_filter1000_v5/busco/${SAMPLE} \
 -l ${BUSCO_db} \
 -m genome \
 --cpu ${SLURM_CPUS_PER_TASK}
```

### 5 - QBT report

```
#!/bin/sh

QBT=lustre/qbt_coassembly_filter1000_v5

HEADERS_SAMPLE=$(ls ${QBT}/busco/ | head -1)

rm -r ${QBT}/all_reports

mkdir -p ${QBT}/all_reports


DATA_DIR=${QBT}/busco/
OUT_FILE=${QBT}/all_reports/busco_report.txt

HEADERS=$(cat ${DATA_DIR}/${HEADERS_SAMPLE}/short_summary.specific.eukaryota_odb10.${HEADERS_SAMPLE}.txt | grep -v '^#' | sed '/^$/d' | grep -v '%' | perl -pe 's/.*\d+\s+//' | tr '\n' '\t')

echo -e "Sample\t${HEADERS}" > ${OUT_FILE}

for SAMPLE in $(ls ${DATA_DIR})
do
  REPORT=$(cat ${DATA_DIR}/${SAMPLE}/short_summary.specific.eukaryota_odb10.${SAMPLE}.txt | \
  grep -v '^#' | perl -pe 's/^\n//' | awk '{print $1}' | tr '\n' '\t')
  echo -e "${SAMPLE}\t${REPORT}" >> ${OUT_FILE}
done


DATA_DIR=${QBT}/tiara/
OUT_FILE=${QBT}/all_reports/tiara_report.txt

for SAMPLE in $(ls ${DATA_DIR} | grep -v "log")
do
  cat ${DATA_DIR}/log_${SAMPLE} | \
  grep -e 'archaea' -e 'bacteria' -e 'eukarya' -e 'organelle' -e 'unknown' -e 'prokarya' -e 'mitochondrion' -e 'plastid' | \
  awk -v var=${SAMPLE} '{print var$0}' OFS='\t' \
  >> ${OUT_FILE}
done


DATA_DIR=${QBT}/quast/
OUT_FILE=${QBT}/all_reports/quast_report.txt

HEADERS=$(cat ${DATA_DIR}/${HEADERS_SAMPLE}/transposed_report.tsv | head -1)

echo -e "Sample\t${HEADERS}" > ${OUT_FILE}

for SAMPLE in $(ls ${DATA_DIR})
do
  REPORT=$(cat ${DATA_DIR}/${SAMPLE}/transposed_report.tsv | tail -1)
  echo -e "${SAMPLE}\t${REPORT}" >> ${OUT_FILE}
done
```

Next steps are explained [here](https://github.com/MassanaLab/SAGs-pipeline?tab=readme-ov-file#braker), starting with BRAKER.
