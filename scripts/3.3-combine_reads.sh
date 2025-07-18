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
