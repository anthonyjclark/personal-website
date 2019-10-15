#!/usr/bin/env bash

# Example:
# https://github.com/alshedivat/al-folio/blob/master/bin/deploy


USAGE_MSG="usage: deploy [--help] [--check] [--format] [--cv] [--build] [--deploy] [--pdf]"

run_all=true
run_check=false
run_format=false
run_cv=false
run_build=false
run_deploy=false
run_pdf=false


while [[ $# > 0 ]]; do
    key="$1"

    case $key in
        --help)
        echo $USAGE_MSG
        exit 0
        ;;
        --check)
        run_all=false
        run_check=true
        ;;
        --format)
        run_all=false
        run_format=true
        ;;
        --cv)
        run_all=false
        run_cv=true
        ;;
        --build)
        run_all=false
        run_build=true
        ;;
        --deploy)
        run_all=false
        run_deploy=true
        ;;
        --pdf)
        run_all=false
        run_pdf=true
        ;;
        *)
        echo "Option $1 is unknown."
        echo $USAGE_MSG
        exit 0
        ;;
    esac
    shift
done


set -e

# Format bib files (only needs to be done when creating a new file)
# biber --tool --output_align --output_indent=2 --output_fieldcase=lower <filename>.bib

bib_dir="./cv-data/bib"
pdf_dir="./src/static/pdf"

bib_json_file="$bib_dir/all_bibs.json"
formatted_bibs="./src/_data/formatted_bibs.json"

formatted_cv_data="./src/_data/cv.json"

if [[ "$run_all" = true || "$run_check" = true ]] ; then
    echo -e "\nCheck all bib files for corresponding pdfs."
    ./bin/check_bibs.py $bib_dir $pdf_dir
fi

if [[ "$run_all" = true || "$run_format" = true ]] ; then
    echo -e "\nConvert and combine all bib files into a json format."
    pandoc-citeproc -j $bib_dir/*.bib > "$bib_json_file"

    echo -e "\nConvert bib data into a format suitable format for eleventy."
    ./bin/format_bibs.py "$bib_json_file" $bib_dir $pdf_dir > "$formatted_bibs"
fi

if [[ "$run_all" = true || "$run_cv" = true ]] ; then
    echo -e "\nConvert toml cv data files to a suitable format for eleventy."
    ./bin/cv_data_to_json.py ./cv-data/sections > "$formatted_cv_data"
fi

if [[ "$run_all" = true || "$run_build" = true ]] ; then
    echo -e "\nBuild site."
    BUILD_MODE=release npx @11ty/eleventy
fi

if [[ "$run_all" = false && "$run_pdf" = true ]] ; then
    echo -e "\nGenerate PDF."
    node ./bin/generate_pdf.js
    mv cv.pdf ./src/static/pdf/Clark.CV.pdf
fi

if [[ "$run_all" = true || "$run_deploy" = true ]] ; then

    read -r -p "Do you want to proceed? [Y/n] " response
    if [[ $response =~ ^([nN][oO]|[nN])+$ ]]
    then
        echo "Aborting."
        [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
    fi

    # Check if there are any uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        echo -e "\nChanges to the following files are uncommitted:"
        git diff-index --name-only HEAD -- | sed 's/^/• /'
        echo "Please commit the changes before proceeding."
        echo "Aborting."
        [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
    fi

    echo -e "\nDeploying site to people.missouristate.edu"

    if mount | grep "on /Volumes/anthonyclark" > /dev/null; then
        echo "The SMB share is already mounted."
    else
        echo "Mounting the SMB share."
        open "smb://people.missouristate.edu/people.missouristate.edu/anthonyclark"
    fi

    until mount | grep "on /Volumes/anthonyclark" > /dev/null; do
        sleep 0.5
        echo "Waiting..."
    done

    # Trailing slashes are important
    site_dir_local="./dist/"
    site_dir_remote="/Volumes/anthonyclark/"

    # Sync with webdev
    rsync -ari --exclude=.DS_Store "$site_dir_local" "$site_dir_remote"

    # Generate pdf from active website
    echo -e "\nGenerate PDF."
    node ./bin/generate_pdf.js
    mv cv.pdf ./src/static/pdf/Clark.CV.pdf

    # Sync newly generate PDF
    rsync -ari "$site_dir_local"/static/pdf/Clark.CV.pdf "$site_dir_remote"/static/pdf/Clark.CV.pdf

    read -p "Do you want to unmount the SMB share? " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        diskutil umount /Volumes/anthonyclark
    fi

    # Commit updated PDF
    git commit -am "Updated CV PDF."

    # Push to github
    git push -u origin master
fi
