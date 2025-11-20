# Grouping SAGs Into Species

## 1 - BLAST: Comparing proteins between SAGs

### 1.1 - Add name to header and concatenate together all protein files  

The first step is to add the name of each sample to its fasta headers. In our case, we had protein files from two different sources, so we repeat this proces of adding the header two times. Then, just concatenate all protein files together.

[1.1-change_names_concatenate.sh](scripts/1.1-change_names_concatenate.sh)  

### 1.2 - Build BLAST Database (`makeblastdb`)  

Once we have all protein fasta files together we must generate a blast database. We do this using `makeblastdb`, in which we indicate the fasta file we need to make the database (`-in`), the type of database we want (`-dbtype`) which in our case is a protein database (`prot`).

[1.2-makeblastdb.sh](scripts/1.2-makeblastdb.sh)

### 1.3 - Run BLAST  
[1.3-blast.sh](scripts/1.3-blast.sh)

### 1.4 - Filter and selection the best BLAST hits  
[1.3-blast.sh](scripts/1.3-blast.sh) *(filtering is handled inside this script)*


## 2 - Average Nucleotide Identity (ANI)

### 2.1 - Extract the needed scaffolds  
[2.1-copy_needed_scaffolds.sh](scripts/2.1-copy_needed_scaffolds.sh)

### 2.2 - Generate input lists  
[2.2-lists_clean.sh](scripts/2.2-lists_clean.sh)

### 2.3 - Build a BLAST database (`makeblastdb`) for each sample  
[2.3-ANI_DB_prep.sh](scripts/2.3-ANI_DB_prep.sh)

### 2.4 - Run BLAST and compute ANI  
[2.4-ANI_blast_fast_launcher.sh](scripts/2.4-ANI_blast_fast_launcher.sh)

### 2.5 - Process ANI results  
[2.5-use_parser_and_sorter.sh](scripts/2.5-use_parser_and_sorter.sh)

Uses [good_sorting_ANI_tables.sh](scripts/good_sorting_ANI_tables.sh) and [ANI_results_parser.sh](scripts/ANI_results_parser.sh).

### 2.6 - Merge all ANI matrices  
[2.6-cat_all_together.sh](scripts/2.6-cat_all_together.sh)


## 3 - Coassembly Preparation: Concatenating Reads

### 3.1 - Gather reads  
*Manual step: place all desired FASTQ files in one folder.*
Start by putting in a folder all the reads from the different SAGs you want to assembly toghether.

### 3.2 - Create coassembly lists  
*Manual step: write `.txt` files with sample names per coassembly.*
Make a .txt file containing all the names of needed individual SAGs that will form each coassembly. Make one .txt file per coassembly, and name this file like x_lists.txt. Ideally, put all this lists in a folder.

### 3.3 - Merge reads for each coassembly  
[3.3-combine_reads.sh](scripts/3.3-combine_reads.sh)
