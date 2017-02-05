#!/bin/bash

# this script does self-blastning, specifically of bacterial genomes downloaded from ENSEMBL

rm longest_repeat_99pct.csv

for FILE in *.fa.gz; do
  # skip genomes in multiple fragments, including those with multiple chromosomes
  NUM=`gunzip -c $FILE | grep -c '>'`
  if (( $NUM == 1 )); then    
  # blast FASTA against itself
  # -perc_identity 100 looks for exact repeats
  # tr removes scaffold-separating Ns, possible source of error
  # sed replaces FASTA header with ensembl id  
    blastn -query <(gunzip -c $FILE | sed 's/.*:.*:\(.*\):.*:.*:.*:.*/>\1/' | tr -d 'N') -subject <(gunzip -c $FILE | tr -d 'N') -perc_identity 99 -outfmt "6 qacc length qstart qend sstart send" >> longest_repeat_99pct.csv
   fi;
done;