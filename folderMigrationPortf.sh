#!/bin/bash
# April Vanravenswaay

# Move AD Project folders to shared server year folders

echo "Starting Folder migration automation..."

# Make log file if it does not exist
echo -n "Checking for log file ...  "
logfile="FolderAutoMigrateLog.txt"
if [ ! -f "$logfile" ]; then
  touch "$logfile"
fi
echo "Done."


#iterate through year folders, move all subdirectories to proper year project folder
yearVar=2014
maxYear=2022
while (($yearVar < $maxYear)); do
    #sanitized directory path for portfolio use
    origin_folder=("directory/"$yearVar"")

 
    #sanitized directory path for portfolio use
    dest_dir=("Directory/"$yearVar" Project Identifiers")
 
    echo "Moving all project folders in "$origin_folder" to "$dest_dir"..."
    if [ ! -d "$dest_dir" ]; then
        mkdir "$dest_dir"
    fi
    for folder in "${origin_folder[@]}"; do
    unset folderList folderName count_success count_fail
    mapfile -d $'\0' folderList < <(find "$folder" -type d -print0)
      for folderName in "${folderList[@]}"; do
        if [ "$folderName" = "$origin_folder" ]; then
          continue
        else
          #echo $folderName
          mv "$folderName" "$dest_dir" 2>/dev/null
        fi
        if (( $? == 0 )); then
          ((count_success++))
          echo "SUCCESS, , moving "$folderName", to "$dest_dir"," >> "$logfile"
        else
          ((count_fail++))
          echo "FAIL, , moving "$folderName", to "$dest_dir"," >> "$logfile"
        fi
      done
    done
    ((yearVar++))
echo "Finished."
echo "   Success: "${count_success}", Fail: "${count_fail}""
done


echo "Automation complete. See the log file for details."
