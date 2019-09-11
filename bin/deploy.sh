#!/usr/bin/env bash

# Example:
# https://github.com/alshedivat/al-folio/blob/master/bin/deploy

set -e

read -r -p "Do you want to proceed? [Y/n] " response
if [[ $response =~ ^([nN][oO]|[nN])+$ ]]
then
    echo "Aborting."
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi


# Check if there are any uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "\nChanges to the following files are uncommitted:"
    git diff-index --name-only HEAD --
    echo "Please commit the changes before proceeding."
    echo "Aborting."
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi


# Format bib files (only needs to be done when creating a new file)
# biber --tool --output_align --output_indent=2 --output_fieldcase=lower <filename>.bib

bib_dir="./cv-data/bib"
pdf_dir="./src/static/pdf"

bib_json_file="$bib_dir/all_bibs.json"
formatted_bibs="./src/_data/formatted_bibs.json"

formatted_cv_data="./src/_data/cv.json"

echo -e "\nCheck all bib files for corresponding pdfs."
./bin/check_bibs.py $bib_dir $pdf_dir

echo -e "\nConvert and combine all bib files into a json format."
pandoc-citeproc -j $bib_dir/*.bib > "$bib_json_file"

echo -e "\nConvert bib data into a format suitable format for eleventy."
./bin/format_bibs.py "$bib_json_file" > "$formatted_bibs"

echo -e "\nConvert toml cv data files to a suitable format for eleventy."
./bin/cv_data_to_json.py ./cv-data/sections > "$formatted_cv_data"

echo -e "\nBuild site."
npx @11ty/eleventy


echo -e "\nDeploying site to people.missouristate.edu"

if mount | grep "on /Volumes/anthonyclark" > /dev/null; then
    echo "The SMB share is already mounted."
else
    echo "Mounting the SMB share."
    open "smb://people.missouristate.edu/courses.missouristate.edu/anthonyclark"
fi

until mount | grep "on /Volumes/anthonyclark" > /dev/null; do
    sleep 0.5
    echo "Waiting..."
done
