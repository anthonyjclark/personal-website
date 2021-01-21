#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from datetime import datetime
from jinja2 import Environment, FileSystemLoader, select_autoescape
from markdown import Markdown
from markdown.extensions.toc import TocExtension
from pathlib import Path
from subprocess import run
import toml

# # Open settings file
# content_file = "140.toml"
# config = toml.load(content_file)

# # run(["./GenerateCalendar.py", content_file, "generated/calendar.md"])
# # run(["./GenerateSchedule.py", content_file, "generated/schedule.md"])
# # run(["./GenerateAssignmentList.py", content_file, "generated/assignments.md"])

# # Process markdown sections

# sections = []

# for filename in config["sections"]:
#     with open(filename, "r") as md_file:
#         sections.append(md_file.read())

# toc_ext = TocExtension(toc_depth=1)
# mdp = Markdown(extensions=["extra", "nl2br", "smarty", toc_ext], output_format="html5")
# html = mdp.convert("\n".join(sections))

# # Render template

# env = Environment(loader=FileSystemLoader("templates"), autoescape=select_autoescape())

# index = env.get_template("index.j2")

# html = index.render(config=config, sections=html, navigation=mdp.toc)

# print(html)



mdp = Markdown(extensions=["extra", "nl2br", "smarty"], output_format="html5")
env = Environment(loader=FileSystemLoader("src/templates"), autoescape=select_autoescape())
base = env.get_template("base.j2")

for md_filename in Path("src/pages").glob("*.md"):

	with md_filename.open() as md_file:
		md_contents = md_file.read()

	page_html = mdp.convert(md_contents)

	html = base.render(title="Anthony J. Clark", description="Professional website for Anthony J. Clark", content=page_html, this_year=str(datetime.today().year))

	if md_filename.stem == "index":
		html_filename = (Path("website")/md_filename.name).with_suffix(".html")
	else:
		html_filename = (Path("website")/md_filename.stem/"index.html")


	webdir = Path("website")
	if md_filename.stem != "index":
		webdir = webdir/md_filename.stem
		webdir.mkdir(parents=True, exist_ok=True)

	html_filename = webdir/"index.html"
	with open(html_filename, "w") as html_file:
		html_file.write(html)

