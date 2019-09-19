#!/usr/bin/env python3

import json
from pathlib import Path
import sys

if len(sys.argv) != 4:
    print("usage: format_bibs.py bibs.json bib_dir pdf_dir", file=sys.stderr)
    exit(1)

bib_filename = sys.argv[1]
bib_dir = Path(sys.argv[2])
pdf_dir = Path(sys.argv[3])

STUDENTS = {
    "Dipto Das", "Glen A. Simon", "Keith A. Cissell", "Jesse Simpson",
    "Jeffrey Dale", "Md Forhad Hossain", "Jared Hall"
}

MONTHS = [
    "MONTH", "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
]


def authors_format(author_list):
    authors = []
    for author in author_list:
        author_str = f'{author["given"]} {author["family"]}'
        if author_str in STUDENTS:
            author_str = f'<span class="bib-author-student">{author_str}</span>'
        elif author_str == "Anthony J. Clark":
            author_str = '<span class="bib-author-ajc">Anthony J. Clark</span>'
        authors.append(author_str)
    if len(authors) == 1:
        return authors[0]
    elif len(authors) == 2:
        return f'{authors[0]} and {authors[1]}'
    else:
        return ", ".join(authors[:-1]) + ", and " + authors[-1]


def venue_format(bib_item):
    venue = bib_item["container-title"]

    short = bib_item.get("event", "")
    short = f" ({short})" if len(short) > 0 else ""
    venue = f'<span class="bib-venue">{venue}{short}'

    place = bib_item.get("publisher-place", "")
    venue += f",</span> {place}." if len(place) > 0 else "</span>."

    if "note" in bib_item:
        note = bib_item["note"]
        venue += f" <strong>{note}</strong>"

    return venue


def date_format(date_list):
    return MONTHS[date_list[1]][:3] + " " + str(date_list[0])


def check_for_slides(bib_key):
    return (pdf_dir / f"{bib_key}-slides.pdf").is_file()


def check_for_award(bib_note):
    return bib_note.lower() == "best paper award"


def get_raw_bibtex(bib_key):
    with open(bib_dir / f"{bib_key}.bib", "r") as bib_file:
        raw_bibtex = bib_file.read()
    return raw_bibtex.replace("{{{", "{&#8203;{&#8203;{").replace("{{", "{&#8203;{")


def main():

    with open(bib_filename, "r") as bib_file:
        bib_data = json.load(bib_file)

    formatted_bibs = []
    for bib in bib_data:
        try:
            formatted_bibs.append({
                "key": bib["id"],
                "title": bib["title"],
                "authors": authors_format(bib["author"]),
                "venue": venue_format(bib),
                "date": date_format(bib["issued"]["date-parts"][0]),
                "year": bib["issued"]["date-parts"][0][0],
                "month_index": bib["issued"]["date-parts"][0][1],
                "award": check_for_award(bib.get("note", "")),
                "doi": bib.get("DOI", ""),
                "slides": check_for_slides(bib["id"]),
                "abstract": bib["abstract"],
                "raw_bibtex": get_raw_bibtex(bib["id"])
            })
        except KeyError as err:
            print(bib["id"], file=sys.stderr)
            raise err

    formatted_bibs.sort(key=lambda bib: (
        bib["year"], bib["month_index"]), reverse=True)

    print(json.dumps(formatted_bibs, indent=4))


main()
