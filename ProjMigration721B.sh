#!/bin/bash
# Meggan M Green & April Vanravenswaay

# Move past AD files into year/project folders

echo "Starting migration automation."

# Make log file if it does not exist
echo -n "Checking for log file ...  "
logfile="AutoMigrateLog.txt"
if [ ! -f "$logfile" ]; then
  touch "$logfile"
fi
echo "Done."

#iterate through year folders in batches
yearVar=1994
maxYear=2018
while (($yearVar < $maxYear)); do
# Origin folders -- minus "ADs" because of bad naming/nesting
#TEST#
origin_dirs=("dirPath/"${yearVar}"")
echo "Selected origin folders: "${origin_dirs[*]}""

# Destination starter
dest_dir="ADs/"
echo "Selected destination folder: "$dest_dir""

# Dir loop
for origin in "${origin_dirs[@]}"; do
  unset filelist filepath count_total count_success count_skip count_fail
  # File list as array (works if spaces or hyphens in the name)
  mapfile -d $'\0' filelist < <(find "$origin" -type f -print0)
  
  # Set counts
  count_total="${#filelist[*]}"
  count_success=0
  count_duplicate=0
  count_skip=0
  count_fail=0
  echo -n "Starting "$count_total" files in "$origin" ...  "

  for filepath in "${filelist[@]}"; do
    unset filename year group proj year_dir target_dir
    filename="$(basename "$filepath")"
  #NE/ANE normal naming convention
    if [[ "$filename" =~ ^([0-9]+)[-]*(ane|ANE|ne|NE)[-]*([0-9]+) ]]; then
      year="${BASH_REMATCH[1]}"
      group="${BASH_REMATCH[2]}"
      proj="${BASH_REMATCH[3]}"

      # Make/Verify 4-digit year or skip -- "10#" forces base-10 comparison for 08 and 09
      if [[ "10#""$year" -lt 19 ]]; then
        year="20""$year"
      elif [[ "10#""$year" -gt 25 && "10#""$year" -le 99 ]]; then
        year="19""$year"
      elif [[ "10#""$year" -gt 1925 && "10#""$year" -lt 2019 ]]; then
        year="$year"
      else
        # Skip file because year is too recent or invalid
        ((count_skip++))
        echo "SKIPPED, YEAR, moving "$filepath", to "$target_dir"," >> "$logfile"
        continue
      fi
      
      # Find/Make year folder -- mostly for testing
      year_dir="$dest_dir""$year""/"
      if [ ! -d "$year_dir" ]; then
	mkdir "$year_dir" 2>/dev/null
        if (( $? != 0 )); then
          # Skip file because could not make target directory
          ((count_skip++))
          echo "SKIPPED, MKDIR YEAR, moving "$filepath", to "$target_dir"," >> "$logfile"
          continue
        fi
      fi

      # Find/Make project folder
      target_dir="$year_dir""$year""-""${group^^}""-""$proj""/"
      if [ ! -d "$target_dir" ]; then
	if [ -d "$target_dir""-AD" ]; then
	  target_dir="$target_dir""-AD"
	else
	  mkdir "$target_dir" 2>/dev/null
          if (( $? != 0 )); then
            # Skip file because could not make target directory
            ((count_skip++))
            echo "SKIPPED, MKDIR PROJ, moving "$filepath", to "$target_dir"," >> "$logfile"
            continue
          fi
        fi
      fi
      
      # Move file -- skip and -n to not overwrite
      if [ -f "$target_dir""$filename" ]; then
        # -i does not work in script, so log the duplicate and continue
	#((count_skip++))
        ((count_duplicate++))
	#handle duplicate files, create backup in case of differing file content
	VERSION_CONTROL=numbered mv -b "$filepath" "$target_dir" 2>/dev/null
	echo "DUPLICATE, OVERWRITE, moving "$filepath", to "$target_dir"," >> "$logfile"
      else
        mv -n "$filepath" "$target_dir" 2>/dev/null
        if (( $? == 0 )); then
          ((count_success++))
          echo "SUCCESS, , moving "$filepath", to "$target_dir"," >> "$logfile"
        else
          ((count_fail++))
          echo "FAIL, , moving "$filepath", to "$target_dir"," >> "$logfile"
        fi
      fi

    else
      # Skip file because could not discern project
      ((count_skip++))
      echo "SKIPPED, PROJ, moving "$filepath", to "$target_dir"," >> "$logfile"
      continue
    fi
  done
  echo "COUNTS, , Total: "${count_total}", Success: "${count_success}", Duplicate: "${count_duplicate}", Skip: "${count_skip}", Fail: "${count_fail}"," >> "$logfile"
  echo "Finished."
  echo "   Success: "${count_success}", Duplicate: "${count_duplicate}", Skip: "${count_skip}", Fail: "${count_fail}""
done
((yearVar++))
done

echo "Automation complete. See the log file for details."
