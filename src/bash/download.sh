# !/bin/bash
# ----------------------------------------------------------------------
# Code to download the data from the source
# 28 oct 2023                                           @roman_avj
# ----------------------------------------------------------------------
# Step 1: Download the data
echo "dowlonading data from source ..."

# create directory & files
mkdir -p data/
output_file="data/paths.txt"
base_url="https://ecobici.cdmx.gob.mx/datos-abiertos/"

# get raw htm
html_content=$(curl -s $base_url)

# get 2023 files
raw_files=$(echo "$html_content" | grep -Eo 'a href="/wp-content/uploads/2023/[0-9]{2}/(ecobici_)?2023(_|-)[0-9]{2}.csv"')
clean_files=$(echo "$raw_files" | sed 's/a href="//;s/"$//' | sed "s|^/|$base_url|;s|datos-abiertos/||") # note: ';' in sed is used to separate commands (pipe commands) # note 2: "|" oe "/" delimits sed old and new strings

# download files
for file in $clean_files; do
    # get month from the file name which is the last numbers before .csv
    month=$(echo "$file" | grep -Eo '[0-9]{2}.csv' | sed 's/.csv//')
    echo "downloading month: $month"
    # download file
    wget -q -O "data/ecobici_$month.csv" "$file"
done

# Step 2: Append data to one file
echo ""
echo "appending data to one file ..."

# read files
all_file=$(ls data/)

# append files
final_file="data/2023ecobici.csv"

# create header
headers=$(head -n 1 "data/ecobici_01.csv")

# append header to final file
echo "$headers" > "$final_file"

# append data
n_lines=0
for file in $all_file; do
    # skip header for each file
    tail -n +2 "data/$file" >> "$final_file"
    # get count of the lines in the file and add it to the total; skip header
    n_lines_file=$(wc -l "data/$file" | grep -Eo '^[0-9]+')
    n_lines_file=$(($n_lines_file - 1))
    # add to total
    n_lines=$(($n_lines + $n_lines_file))
done

# Step 3: verify append is done correctly
# get count of lines in final file
n_lines_final=$(wc -l "$final_file" | grep -Eo '^[0-9]+')
n_lines_final=$(($n_lines_final - 1)) # remove header

# print
echo ""
if [ $n_lines -eq $n_lines_final ]; then
    echo "append done correctly"
    echo "there are $n_lines_final lines in the final file"
else
    echo "append failed"
fi