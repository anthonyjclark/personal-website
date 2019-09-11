#!/usr/bin/env python3

from pathlib import Path
import sys

if len(sys.argv) != 3:
    print("usage: check_bibs.py bib_dir pdf_dir", file=sys.stderr)
    exit(1)

bib_dir = Path(sys.argv[1])
pdf_dir = Path(sys.argv[2])

pdf_files = set([str(f) for f in pdf_dir.glob("*.pdf")])

for bib in bib_dir.glob("*.bib"):
    with open(bib, "r") as bib_file:
        bib_key = bib_file.readline().strip().split("{")[1][:-1]

    # Check bib key
    if bib.name[:-4] != bib_key:
        print("WARNING: bib key is wrong for", bib)

    # Check for pdf of paper
    pdf = pdf_dir / bib.with_suffix(".pdf").name
    if not pdf.is_file():
        print("WARNING: pdf not found for", pdf)
    else:
        pdf_files.remove(str(pdf))

    # Check for pdf of presentation
    pres = str(pdf_dir / (bib.stem + "-slides.pdf"))
    if pres in pdf_files:
        pdf_files.remove(pres)

for pdf_file in pdf_files:
    print(f"WARNING: found non-publication pdf", pdf_file)
