# 1 - BLAST: Comparing proteins between SAGs

### 1.1 - Change Names & Concatenate

### 1.2 - makeblastdb

### 1.3 - BLAST

### 1.4 - Selection from BLAST results

# 2 - Average Nucleotide Identity (ANI)

### 2.1 - Copy needed scaffolds

### 2.2 - Create lists

### 2.3 - makeblastdb for each sample

### 2.4 - BLAST and calculate ANI with formula

### 2.5 - Process ANI results

### 2.6 - Put all ANI matrices together



# 3 - Concatenate reads from selected samples

### 3.1 - Prepare reads

Start by putting in a folder all the reads from the different SAGs you want to assembly toghether.

### 3.2 -  Prepare lists

Make a .txt file containing all the names of needed individual SAGs that will form each coassembly. Make one .txt file per coassembly, and name this file like x_lists.txt. Ideally, put all this lists in a folder.

### 3.3 - Combine reads

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
