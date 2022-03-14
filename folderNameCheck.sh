#!/bin/bash
#April VanRavenswaay

#Check if project folders end in -AD, rename and consolidate as needed

echo "Starting folder automation and renaming..."

#Make log file if does not exist
echo -n "Checking for log file..."
logfile="folderNameCheckLog.txt"
if [ ! -f "$logfile" ]; then
  touch "$logfile"
fi
echo "Done."

yearVar=2018
maxYear=2019

while (($yearVar < $maxYear)); do
  origin_dirs=("dirPath/"${yearVar}"")
  echo "Origin folder: "${origin_dirs}""
  correct=0
  consolidate=0
  rename=0
#dir loop
  for d in "${origin_dirs}"/*; do
    if [[ "$d" == *"AD" ]]; then
      ((correct++))
      echo "CORRECT, directory name "$d"," >> "$logfile"
    else
      if [[ -d "$d""-AD" ]]; then
	mv -n "$d"/* "$d""-AD"
	rm -r "$d"
	((consolidate++))
	echo "-AD DIR EXISTS, moved "$d", to "$d"-AD," >> "$logfile"
      else
        mv "$d" "$d""-AD"
	((rename++))
	echo "-AD DIR NOT FOUND, renamed "$d", to "$d"-AD," >> "$logfile"
      fi      
    fi
  done
echo "Automation complete: Correct= "$correct", Consolidated= "$consolidate", Renamed= "$rename"."
((yearVar++))
done