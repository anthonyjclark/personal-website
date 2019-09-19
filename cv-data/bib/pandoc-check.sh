#!/usr/bin/env bash

for f in *.bib
do
    echo "Testing" "$f"
    pandoc-citeproc -j $f > /dev/null
done
