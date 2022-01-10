#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from datetime import datetime
from jinja2 import Environment, FileSystemLoader, select_autoescape
from markdown import Markdown
from markdown.extensions.toc import TocExtension
from pathlib import Path
from subprocess import run

import json
# import toml

MONTHS = [
    "Blank", "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
]

mdp = Markdown(extensions=["extra", "nl2br", "smarty"], output_format="html5")
env = Environment(loader=FileSystemLoader("src/templates"), autoescape=select_autoescape())

def to_datetime(ymd):
	if ymd == "present":
		return "present"
	else:
		y, m, d = ymd.split("-")
		return datetime(int(y), int(m), int(d))

def cvdate_filter(datestr):

	if datestr is None:
		return ""

	datestr = datestr.strip()

	if len(datestr) == 0:
		return ""

	dates = [to_datetime(ymd) for ymd in datestr.split(" to ")]

	first_month = MONTHS[dates[0].month][:3]
	first_year = dates[0].year

	date = first_month

	if len(dates) > 1:
		if "present" in datestr:
			date += f" {first_year} to present"
		else:
			second_month = MONTHS[dates[1].month][:3]
			second_year = dates[1].year

			if second_year != first_year:
				date += f" {first_year}"

			date += f" to {second_month} {second_year}"

	else:
		date += f" {first_year}"

	return date

def md_filter(md_text):
	return mdp.convert(md_text)


env.filters["cvdate"] = cvdate_filter
env.filters["markdown"] = md_filter

cv = env.get_template("cv.j2")

with open("src/_data/cv.json", "r") as cv_datafile:
	cv_data = json.load(cv_datafile)

with open("src/_data/formatted_bibs.json", "r") as bib_datafile:
	bib_data = json.load(bib_datafile)

cv_html = cv.render(
	cv=cv_data,
	this_month=f"{MONTHS[datetime.today().month][:3]} {datetime.today().year}",
	formatted_bibs=bib_data)

base = env.get_template("base.j2")
html = base.render(
	title="Anthony J. Clark",
	description="Professional website for Anthony J. Clark",
	content=cv_html,
	this_year=str(datetime.today().year))


webdir = Path("website")/"cv"
webdir.mkdir(parents=True, exist_ok=True)

html_filename = webdir/"index.html"
with open(html_filename, "w") as html_file:
	html_file.write(html)
