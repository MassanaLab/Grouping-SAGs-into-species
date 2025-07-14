for TAX in $(ls lists/ | sed 's/_lists.txt//g')
do

	OUT=data/clean/scaffolds_needed/${TAX}_scaffolds

	rm -r ${OUT}

	mkdir -p ${OUT}

	while read line;
	do

		cp /mnt/smart/shared/massanalab3/guillem/ALACANT_227_filter3_final_folders/${line}/${line}_filter3_clean_scaffolds.fasta ${OUT}
		cp /mnt/smart/shared/massanalab3/guillem/LEUVEN_74_filter3_final_folders/${line}/${line}_filter3_clean_scaffolds.fasta ${OUT}
		cp /mnt/cold02/bio/massanalab2/02-PROCESSED_DATA/BL_SAGS_180508/0_81_Indv_SAGs_assemblies/${line}*/*_assembly.fasta ${OUT}

	done < lists/${TAX}_lists.txt

done
