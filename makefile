WEBDIR = website
# GENDIR = src/generated

# CSS_SOURCE = $(wildcard src/css/*.css)
# JS_SOURCE = $(wildcard src/js/*.js)
IMG_SOURCE =  $(wildcard src/img/*)
STATIC_SOURCE = $(wildcard src/static/*)

#
# Build index
#

.PHONY: all
# all: gen css js img $(WEBDIR)/index.html
all: img static $(WEBDIR)/index.html

# $(WEBDIR)/index.html: $(GENDIR)/calendar.md $(GENDIR)/schedule.md sections/*.md templates/*.j2 140.toml bin/GeneratePages.py | $(WEBDIR) $(GENDIR)
# 	bin/GeneratePages.py > $@
$(WEBDIR)/index.html: src/pages/*.md src/templates/*.j2 bin/GeneratePages.py bin/GenerateCV.py | $(WEBDIR) $(GENDIR)
	bin/GeneratePages.py
	bin/GenerateCV.py


$(WEBDIR):
	echo "hello"
	mkdir -p $(WEBDIR)/img #$(WEBDIR)/css $(WEBDIR)/js

#
#  Build generated md files
#

# .PHONY: gen
# gen: $(GENDIR)/calendar.md $(GENDIR)/schedule.md

# $(GENDIR)/calendar.md: 140.toml bin/GenerateCalendar.py | $(GENDIR)
# 	bin/GenerateCalendar.py $< > $@

# $(GENDIR)/schedule.md: 140.toml bin/GenerateSchedule.py | $(GENDIR)
# 	bin/GenerateSchedule.py $< > $@

$(GENDIR):
	#mkdir -p $(GENDIR)

# #
# # Build css
# #

# # CSS_COPIES = $(CSS_SOURCE:%=$(WEBDIR)/%)

# .PHONY: css
# css: $(WEBDIR)/css/main.css

# $(WEBDIR)/css/main.css: $(CSS_SOURCE) | $(WEBDIR)
# 	cat $^ > $@

# #
# # Build js
# #

# .PHONY: js
# js: $(WEBDIR)/js/main.js

# $(WEBDIR)/js/main.js: $(JS_SOURCE) | $(WEBDIR)
# 	cat $^ > $@

#
# Build img
#

# IMG_COPIES = $(IMG_SOURCE:%=$(WEBDIR)/%)
IMG_COPIES = $(subst src,$(WEBDIR),$(IMG_SOURCE))

.PHONY: img
img: $(IMG_COPIES)

$(WEBDIR)/img/%: src/img/% | $(WEBDIR)
	cp $< $@

STATIC_COPIES = $(subst src/static,$(WEBDIR),$(STATIC_SOURCE))

.PHONY: static
static: $(STATIC_COPIES)

$(WEBDIR)/%: src/static/% | $(WEBDIR)
	cp $< $@

#
# Helpers
#

.PHONY: clean
clean:
	rm -rf $(WEBDIR) #$(GENDIR)
