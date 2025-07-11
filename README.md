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

### 6 - Merge QBT reports

```
rm(list = ls())

library(readr)
library(dplyr)
library(tidyr)
library(readxl)

#DATA_DIR <- "lustre/qbt_test_filter/all_reports/"

getwd()

#setwd("Desktop/ICM-CSIC/CESGA/QBT_DAVID_8_COASS/")

rm(list = ls())

for (x in c(1)) {
    
    DATA_DIR <- "all_reports/"
    
    quast <- read_tsv(sprintf("%squast_report.txt", DATA_DIR))
    busco <- read_tsv(sprintf("%sbusco_report.txt", DATA_DIR))
    tiara <- read_tsv(sprintf("%stiara_report.txt", DATA_DIR), col_names = c('Sample', 'tiara'))
    
    tiara <- 
        tiara %>% 
        separate(tiara, sep = ': ', into = c('tax', 'n')) %>% 
        mutate(n = as.numeric(n)) %>% 
        group_by(Sample, tax) %>% 
        summarise(n = sum(n), .groups = 'drop') %>% 
        pivot_wider(names_from = tax, values_from = n, values_fill = 0) %>%
        mutate(across(where(is.numeric), ~round(., 1))) %>%  # Round numeric columns
        select(
            Sample,
            everything(),
            -any_of("organelle")
        ) %>%
        rowwise() %>%  # Ensure `all_tiara` sums only included columns
        mutate(
            all_tiara = sum(c_across(where(is.numeric)), na.rm = TRUE),
            `%-euk` = round(100 * ifelse("eukarya" %in% names(.), eukarya / all_tiara, 0), 1),
            `%-prok` = round(100 * sum(c_across(matches("bacteria|prokarya|archaea")), na.rm = TRUE) / all_tiara, 1)
        ) %>%
        ungroup() %>%
        select(
            Sample,
            `%-euk`,
            `%-prok`,
            any_of(c("eukarya", "bacteria", "archaea", "prokarya", "unknown", "mitochondrion", "plastid")),  # Keep only available columns in preferred order
            everything(),  # Any remaining columns
            -all_tiara,  # Temporarily remove all_tiara
            all_tiara  # Add all_tiara at the end
        )
    
    
    
    
    

    
    base <- data.frame(matrix(NA, nrow = nrow(quast), ncol = 14))
    
    colnames(base) <- c("Sample", "Mb (>= 0 )", "Mb (> =1k)", "Mb (>= 3kb)", "Mb (>= 5Kb)", "contigs (>= 1Kb)", "contigs (>= 3Kb)", "contigs (>= 5Kb)", "Largest contig", "GC (%)", "N50", "Complete BUSCOs", "Fragmented BUSCOs", "Completeness (%) (out of 255)")
    
    
    ### QUAST 
    
    base$Sample <- quast$Sample
    
    base[2:5] <- round(quast[7:10] / 1000000, 2)
    
    base[6:8] <- quast[4:6]
    
    base$`Largest contig` <- quast$`Largest contig`
    
    base$`GC (%)` <- quast$`GC (%)`
    
    base$N50 <- quast$N50
    
    
    ### BUSCO
    
    colnames(busco) <- c("Sample", "X", "Results", "Complete", "Complete and Single", "Complete and Duplicated", "Fragmented", "Missing", "X2", "X3", "X4")
    
    base$`Complete BUSCOs` <-  busco$Complete
    
    base$`Fragmented BUSCOs` <- busco$Fragmented
    
    base$`Completeness (%) (out of 255)` <- round(100*(base$`Complete BUSCOs` + base$`Fragmented BUSCOs`)/255, 2)
    
    
    ### TIARA
    
    #tiara <- select(tiara2, Sample, colnames(tiara2)[3:ncol(tiara2)], all_tiara)
    
    base2 <- left_join(base, tiara, by = "Sample")
    
    ### Write final summary table
    
    #colnames(base2) <- c("Sample", "Mb (>= 0 )", "Mb (> =1k)", "Mb (>= 3kb)", "Mb (>= 5Kb)", "contigs (>= 1Kb)", "contigs (>= 3Kb)", "contigs (>= 5Kb)", "Largest contig", "GC (%)", "N50", "Complete BUSCOs", "Fragmented BUSCOs", "Completeness (%) (out of 255)", colnames(tiara)[3:ncol(tiara)], "all tiara")
    
    base2[is.na(base2)] <- 0
    
    write.table(base2, file = "QBT_summary_david_8_coass.tsv", sep = "\t", row.names = FALSE)   
}
```

Next steps are explained [here](https://github.com/MassanaLab/SAGs-pipeline?tab=readme-ov-file#braker), starting with BRAKER.
