# Grouping SAGs Into Species

## 1 - BLAST: Comparing proteins between SAGs

### 1.1 - Add name to header and concatenate together all protein files

### 1.2 - Build BLAST Database (`makeblastdb`)

### 1.3 - Run BLAST

### 1.4 - Filter and selection the best BLAST hits


## 2 - Average Nucleotide Identity (ANI)

### 2.1 - Extract the needed scaffolds

### 2.2 - Generate input lists

### 2.3 - Build a BLAST databse (`makeblastdb`) for each sample

### 2.4 - Run BLAST and compute ANI

### 2.5 - Process ANI results

### 2.6 - Merge all ANI matrices


## 3 - Coassembly Preparation: Concatenating Reads

### 3.1 - Gather reads

Start by putting in a folder all the reads from the different SAGs you want to assembly toghether.

### 3.2 -  Create coassembly lists

Make a .txt file containing all the names of needed individual SAGs that will form each coassembly. Make one .txt file per coassembly, and name this file like x_lists.txt. Ideally, put all this lists in a folder.

### 3.3 - Merge reads for each coassembly

