#!/bin/bash

# Create the lists_clean folder if it doesn't exist
mkdir -p lists_clean

# Loop through each .txt file in the lists folder
for file in lists/tax20_*.txt; do

    # Get the filename without the path
    filename=$(basename "$file")
    
    # Apply sed to clean the content and save to lists_clean folder
    sed 's/R.*//' "$file" > "lists_clean/$filename"
    
    echo "Cleaned file: $filename"

done

