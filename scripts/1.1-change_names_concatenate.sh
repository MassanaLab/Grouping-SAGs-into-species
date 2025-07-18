OUT=lustre/add_sample_to_headder_alacant+leuven

mkdir -p ${OUT}

SOURCE_ALAC=store/braker_ALACANT/aa

for SAMPLE in $(cat data/clean/Alacant_SAGs_sel_227.txt)
do

 sed "s/>.*/&_${SAMPLE}/g" ${SOURCE_ALAC}/${SAMPLE}_augustus.hints.aa > ${OUT}/${SAMPLE}_augustus.hints_hdr.aa

done


SOURCE_LEUVEN=store/braker_LEUVEN/aa

for SAMPLE in $(cat data/clean/Leuven_sel_34.txt)
do

 sed "s/>.*/&_${SAMPLE}/g" ${SOURCE_LEUVEN}/${SAMPLE}_augustus.hints.aa > ${OUT}/${SAMPLE}_augustus.hints_hdr.aa

done


cat ${OUT}/* > store/all_alacant+leuven.aa

#rm -r ${OUT}
