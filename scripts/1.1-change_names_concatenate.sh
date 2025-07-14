OUT=lustre/add_sample_to_headder

mkdir -p ${OUT}

SOURCE=store/braker_ALACANT/aa



for SAMPLE in $(cat data/clean/Alacant_SAGs_sel_227.txt)
do

 sed "s/>.*/&_${SAMPLE}/g" ${SOURCE}/${SAMPLE}_augustus.hints.aa > ${OUT}/${SAMPLE}_augustus.hints_hdr.aa

done

cat ${OUT}/* > store/all_aa.aa

#rm -r ${OUT}
