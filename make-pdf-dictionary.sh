#!/bin/bash

# this program takes a directory full of PDFs and makes a dictionary of the most frequently used words

# requires calibre's ebook-convert
# sudo apt-get install calibre

ls *.pdf | parallel ebook-convert {} {}.txt

for FILE in *.pdf.txt; do 
  cat $FILE | sed -r 's/[[:space:]]/\n/g;' | sed -r 's/[^[:alpha:]]//g;' | tr '[:upper:]' '[:lower:]' | awk 'length($0) > 4' | sort > $FILE.filter.txt; 
done

for FILE1 in *.filter.txt; do 
  echo $FILE1; 
  for FILE2 in *.filter.txt; do 
    if [ "$FILE1" < "$FILE2" ]; then 
      comm -12 $FILE1 $FILE2 | sort >> comps.txt; 
      uniq comps.txt > compsu.txt; 
    fi; 
  done; 
done

#if the word is used more than 10 times among all papers
sort comps.txt | uniq -c | sort -rn > comps2.txt
awk '{if($1 > 10) print $2,$1}' comps2.txt | sort > dictionary-bywords.txt

#if the word is present in more than 3 papers
sort compsu.txt | uniq -c | sort -rn > comps2u.txt
awk '{if($1 > 3) print $2,$1}' comps2u.txt | sort > dictionary2-bydocs.txt

mkdir compare_out
mv comp*.txt compare_out/
my *.pdf.* compare_out/
