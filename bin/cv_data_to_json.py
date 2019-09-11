#!/usr/bin/env python3

import json
from pathlib import Path
from tomlkit import parse
import sys

if len(sys.argv) != 2:
    print("usage: cv_data_to_json.py cv_toml_dir", file=sys.stderr)
    exit(1)

toml_fnames = Path(sys.argv[1]).glob("*.toml")

combined_sections = {}

for toml_fname in toml_fnames:
    with open(toml_fname, "r") as toml_file:
        section_data = parse(toml_file.read())
        combined_sections.update(section_data)

print(json.dumps(combined_sections, indent=4))
