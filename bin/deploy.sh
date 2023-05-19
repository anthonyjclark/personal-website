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

mkdir -p "./src/_data/"
mkdir -p "website"

bib_dir="./cv-data/bib"
pdf_dir="./src/pdf"

bib_json_file="$bib_dir/all_bibs.json"
formatted_bibs="./src/_data/formatted_bibs.json"

formatted_cv_data="./src/_data/cv.json"

if [[ "$run_all" = true || "$run_check" = true ]] ; then
	echo -e "\nCheck all bib files for corresponding pdfs."
	./bin/check_bibs.py $bib_dir $pdf_dir
fi

if [[ "$run_all" = true || "$run_format" = true ]] ; then
	echo -e "\nConvert and combine all bib files into a json format."
	# pandoc-citeproc -j $bib_dir/*.bib > "$bib_json_file"
	pandoc --citeproc cv-data/bib/*.bib -t csljson > "$bib_json_file"

	echo -e "\nConvert bib data into a simpler format."
	./bin/format_bibs.py "$bib_json_file" $bib_dir $pdf_dir > "$formatted_bibs"
fi

if [[ "$run_all" = true || "$run_cv" = true ]] ; then
	echo -e "\nConvert toml cv data files to a simpler format."
	./bin/cv_data_to_json.py ./cv-data/sections > "$formatted_cv_data"
fi

if [[ "$run_all" = true || "$run_build" = true ]] ; then
	echo -e "\nBuild site."
	./bin/GeneratePages.py
	./bin/GenerateCV.py
	mkdir -p ./website/img
	cp ./src/img/* ./website/img/
	cp ./src/static/* ./website/
	# make
fi

# if [[ "$run_all" = false && "$run_pdf" = true ]] ; then
#     echo -e "\nGenerate PDF."
#     node ./bin/generate_pdf.js
#     mv cv.pdf ./src/static/pdf/Clark.CV.pdf
# fi

if [[ "$run_all" = true || "$run_deploy" = true ]] ; then

	read -r -p "Do you want to upload to the server and push changes? [Y/n] " response
	if [[ $response =~ ^([nN][oO]|[nN])+$ ]]
	then
		echo "Aborting."
		[[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
	fi

	echo -e "\nDeploying site to smb://ajcd2020@WellsAF/Fac-Staff/ajcd2020"

	# echo -e "\nConnecting to VPN"

	# printf "\n\n$(security find-internet-password -s wells.campus.pomona.edu -w)\n" | \
	#        /opt/cisco/anyconnect/bin/vpn -s connect anyconnect.pomona.edu > /dev/null

	echo -e "\nMounting network drive"
	mkdir -p www
	mount -t smbfs "//ajcd2020:$(security find-internet-password -s wells.campus.pomona.edu -w)@WellsAF/Fac-Staff/ajcd2020" www

	# if mount | grep "on /Volumes/anthonyclark" > /dev/null; then
	#     echo "The SMB share is already mounted."
	# else
	#     echo "Mounting the SMB share."
	#     open "smb://people.missouristate.edu/people.missouristate.edu/anthonyclark"
	# fi

	# until mount | grep "on /Volumes/anthonyclark" > /dev/null; do
	#     sleep 0.5
	#     echo "Waiting..."
	# done

	# # Trailing slashes are important
	# site_dir_local="./website/"
	# site_dir_remote="/Volumes/anthonyclark/"

	# # Sync with webdev
	# rsync -ari --exclude=.DS_Store "$site_dir_local" "$site_dir_remote"
	echo "Syncing data..."
	$HOME/.local/bin/cpsync website/ "www/My Documents/My Webs/"

	# Create remote PDF directory
	mkdir -p "www/My Documents/My Webs/pdf"

	# Copy PDFS over
	$HOME/.local/bin/cpsync "$pdf_dir/" "www/My Documents/My Webs/pdf/"
	$HOME/.local/bin/cpsync "$bib_dir/" "www/My Documents/My Webs/bib/"

	# Generate pdf from active website
	echo -e "\nGenerate PDF."
	# # BUILD_MODE=release node ./bin/generate_pdf.js
	# # cp cv.pdf ./src/static/pdf/Clark.CV.pdf
	# # mv cv.pdf "$site_dir_local"/static/pdf/Clark.CV.pdf
	"/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" --headless --disable-gpu --print-to-pdf=Clark.CV.pdf --no-pdf-header-footer https://cs.pomona.edu/~ajc/cv/

	# Sync newly generate PDF
	$HOME/.local/bin/cpsync Clark.CV.pdf "www/My Documents/My Webs/pdf/Clark.CV.pdf"

	# echo
	# read -p "Do you want to unmount the SMB share? " -n 1 -r
	# echo
	# if [[ $REPLY =~ ^[Yy]$ ]]; then
	#     diskutil umount /Volumes/anthonyclark
	# fi
	until diskutil unmount www; do echo "Trying again..."; sleep 2; done

	# /opt/cisco/anyconnect/bin/vpn disconnect > /dev/null



	# Check if there are any uncommitted changes
	if ! git diff-index --quiet HEAD --; then
		echo -e "\nChanges to the following files are uncommitted:"
		git diff-index --name-only HEAD -- | sed 's/^/• /'
	fi

	echo -e "\nPush to github."
	git push -u origin master
fi
