rm -r data/clean/ANI_tables_temp/

rm -r data/clean/ANI_tables_sorted/


for TAX in $(ls lists_clean/ | sed 's/_lists.txt//g')
do

	bash \
		scripts/ANI_results_parser.sh \
		lists_clean/${TAX}_lists.txt \
		data/clean/ANI_results/${TAX}_ANI_results/

done


bash scripts/good_sorting_ANI_tables.sh
