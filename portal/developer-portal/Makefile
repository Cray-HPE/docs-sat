# (C) Copyright 2021 Hewlett Packard Enterprise Development LP
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

# Based on Makefile by Facundo Muñoz (2018)
# Modified by Dogukan Cagatay <dcagatay@gmail.com>
# Originally from : http://tex.stackexchange.com/a/40759
# Modified for compilation of Markdown files with ideas from
# http://plain-text.co/pull-it-together.html
# Modified to build MD from MDS files
# Modified to build tar
# Modified to spellcheck
# Modified to lint

ifdef RPM_BUILD_ROOT
RPM_BUILD_ROOT := $(RPM_BUILD_ROOT)
else
RPM_BUILD_ROOT := `pwd`
endif

## Build dir
BUILDDIR = build

SOURCEDIR = .
OPENAPI = ../openapi
TMPDIR = ./tmp

PDFBUILDDIR = $(BUILDDIR)/pdf
HTMLBUILDDIR = $(BUILDDIR)/html
MDSBUILDDIR = $(SOURCEDIR)
YAMLBUILDDIR = $(BUILDDIR)/html

IMAGESDIR = images
CSSDIR = css

## Target file names with extensions (use substitution references)
## https://www.gnu.org/software/make/manual/make.html#Substitution-Refs

## Expands to a list of all markdown files in the working directory
MD_SRC = $(wildcard $(SOURCEDIR)/*.md)
MDS_SRC = $(wildcard $(SOURCEDIR)/*.mds)
CHK_SRC = $(wildcard $(SOURCEDIR)/*.mds)
YAML = $(wildcard $(OPENAPI)/*.yaml)
YAML_SRC = $(patsubst %.page.yaml,%.yaml,$(wildcard $(YAML)) )

## Expands to list of .html, .pdf, .md objects to build based on .md and .mds
## x.pdf depends on x.md, x.html depends on x.md, x.md depends on x.mds, etc
## pdfs can be built from all md and tex files

# Need dependency when .mds contains other mds's and add to clean

Operations_Guide_Customer.md: taxonomy.md install_sw.md admin_sw.md
Operations_Guide_Manufacturing.md: taxonomy.md install_sw.md install_hw.md admin_sw.md

MDOBJECTS = $(patsubst %.mds,%.md,$(MDS_SRC))

CHKOBJECTS = $(patsubst %.mds,%.md,$(MDS_SRC))

HTMLOBJECTS = $(patsubst $(SOURCEDIR)/%.md,$(HTMLBUILDDIR)/%.html,$(MD_SRC))

HTMLOBJECTS2 = $(patsubst $(SOURCEDIR)/%.mds,$(HTMLBUILDDIR)/%.html,$(MDS_SRC))

YAMLOBJECTS = $(patsubst $(OPENAPI)/%.yaml,$(YAMLBUILDDIR)/%.html,$(YAML_SRC))

PDFOBJECTS = $(patsubst $(SOURCEDIR)/%.md,$(PDFBUILDDIR)/%.pdf,$(MD_SRC))

PDFOBJECTS2 = $(patsubst $(SOURCEDIR)/%.mds,$(PDFBUILDDIR)/%.pdf,$(MDS_SRC))


# MAIN LATEXMK RULE
# -pdf tells latexmk to generate PDF directly (instead of DVI).
# -pdflatex="" tells latexmk to call a specific backend with specific options.
# -use-make tells latexmk to call make for generating missing files.
# -interactive=nonstopmode keeps the pdflatex backend from stopping at a
# missing file reference and interactively asking you for an alternative.
# Left for reference:
# LATEXMK = latexmk -use-make -pdf -pdflatex="pdflatex -interactive=nonstopmode"

# Convert .mds to .md file
COMPILEMDS = ../../scripts/compileMDS.py
MKVERSION = ../../setup_versioning.sh

# PANDOC experiments for reference
#

PANDOC-N = pandoc -c $(CSSDIR)/H.css -s --toc -V urlcolor:blue -V linkcolor:blue -V monofontoptions:"Scale=0.4" -V geometry:"top=2cm, bottom=1.5cm, left=1.5cm, right=1.5cm" --pdf-engine=xelatex --number-sections -H ./pdf-templates/fancy.tex 

PANDOC = docker run --rm --volume "`pwd`:/data" --user `id -u`:`id -g` pandoc/latex:2.6 -c css/H.css -s --toc -V urlcolor:blue -V linkcolor:blue -V monofontoptions:"Scale=0.4" -V geometry:"top=2cm, bottom=1.5cm, left=1.5cm, right=1.5cm" --pdf-engine=xelatex  --number-sections -H ./pdf-templates/fancy.tex

HTMLPANDOC = docker run --rm --volume "`pwd`:/data" --user `id -u`:`id -g` pandoc/latex:2.6 -c css/H.css -s --toc -V urlcolor:blue -V linkcolor:blue --to html5 --number-sections

HTMLPANDOC-N = pandoc -c css/H.css -s --toc  -V urlcolor:blue -V linkcolor:blue --to html5 --number-sections

REDOC = docker run -v "`pwd`/..:/data" broothie/redoc-cli:0.9.8 bundle
MDL =	docker run --rm -v `pwd`:/workspace  -v `pwd`/lint/.mdlrc:/mdl/.mdlrc wpengine/mdl /workspace
MDL-N =	mdl *.md 


# Also, include non-file targets in .PHONY so they are run regardless of any
# file of the given name existing.
.PHONY: all

# Rules -- make all, make pdf, make html. The `clean` rule is below.
# The first rule in a Makefile is the one executed by default ("make"). It
# should always be the "all" rule, so that "make" and "make all" are identical.

all:    dir md pdf html api

md:	    dir $(MDOBJECTS)

pdf:    dir md $(PDFOBJECTS) $(PDFOBJECTS2)

html:   dir md $(HTMLOBJECTS) $(HTMLOBJECTS2)

api:    dir md $(YAMLOBJECTS)

## For future, used if build artifacts do not perfectly align to .mds files
## Then, create a pscript.sh in this directory with explicit pandoc commands
## Not necessary in this case.
##
## pscript: dir md
## 	docker run --rm --volume "`pwd`:/data" --user `id -u`:`id -g` --entrypoint "/data/pscript.sh" pandoc/latex:2.6

## Implicit rules
## https://www.gnu.org/software/make/manual/html_node/Using-Implicit.html#Using-Implicit
## Each implicit rule has a arget pattern and prerequisite patterns.
## There may be many implicit rules with the same target pattern
## The rule that actually applies is the one whose prerequisites exist or can be made

## '$@' is a variable holding the name of the target,
## and '$<' is a variable holding the (first) dependency of a rule.

dir: $(TMPDIR)/VeRsIoN.md pdf-templates/fancy.tex
	mkdir -p $(PDFBUILDDIR)
	mkdir -p $(HTMLBUILDDIR)
	cp -r $(IMAGESDIR) $(HTMLBUILDDIR)
	cp -r $(CSSDIR) $(HTMLBUILDDIR)


## Setup Version/Copyright for Doc section, and for Doc page footers
$(TMPDIR)/VeRsIoN.md pdf-templates/fancy.tex:
	mkdir -p $(TMPDIR)
	$(MKVERSION) -d > $(TMPDIR)/VeRsIoN.md

# Some build environments may not have docker installed
# In this case, specify make NODOCKER='y', and
# Pandoc must be installed locally

ifdef NODOCKER
$(HTMLBUILDDIR)/%.html: $(SOURCEDIR)/%.md
	$(HTMLPANDOC-N) -o $@ $(TMPDIR)/VeRsIoN.md $< 

$(PDFBUILDDIR)/%.pdf: $(SOURCEDIR)/%.md
	$(PANDOC-N) -o $@ $(TMPDIR)/VeRsIoN.md $< 
else
$(HTMLBUILDDIR)/%.html: $(SOURCEDIR)/%.md
	$(HTMLPANDOC) -o $@ $(TMPDIR)/VeRsIoN.md $< 

$(PDFBUILDDIR)/%.pdf: $(SOURCEDIR)/%.md
	$(PANDOC) -o $@ $(TMPDIR)/VeRsIoN.md $< 
endif


$(SOURCEDIR)/%.md: $(SOURCEDIR)/%.mds
	$(COMPILEMDS) $<

$(YAMLBUILDDIR)/%.html: $(OPENAPI)/%.yaml
	$(REDOC) openapi/`basename $<` -o developer-portal/$@

clean:
	rm -fr $(BUILDDIR)
	rm -fr $(TMPDIR)
	rm -f $(MDOBJECTS)


spellcheck: clean md
	mkdir -p $(TMPDIR);touch $(TMPDIR)/spellerrors.txt
	$(foreach mdobj,$(CHKOBJECTS), echo "===== $(mdobj)" >> $(TMPDIR)/spellerrors.txt;pandoc --lua-filter ../spelling/spellcheck.lua $(mdobj) >> $(TMPDIR)/spellerrors.txt;)
	@if [ `grep -v ===== ./tmp/spellerrors.txt | wc -l` -ne 0 ]; then \
		cat ./tmp/spellerrors.txt ; \
		exit ;\
	fi;\

ifdef NODOCKER
lint: clean md
	$(MDL-N)
else
lint: clean md
	$(MDL)
endif

test:
	echo 'ybuilddir'
	echo $(YAMLBUILDDIR)
	echo 'src'
	echo $(MD_SRC)
	echo 'mds'
	echo $(MDS_SRC)
	echo 'html'
	echo $(HTMLOBJECTS)
	echo 'html2'
	echo $(HTMLOBJECTS2)
	echo 'pdf'
	echo $(PDFOBJECTS)
	echo 'pdf2'
	echo $(PDFOBJECTS2)
	echo 'md'
	echo $(MDOBJECTS)
	echo 'yamlobjs'
	echo $(YAMLOBJECTS)
	echo 'yamlsrc'
	echo $(YAML_SRC)

tar: all $(BUILDDIR)/pdfhtml.tar
	rm $(TMPDIR)/VeRsIoN.md

$(BUILDDIR)/pdfhtml.tar: $(HTMLOBJECTS) $(PDFOBJECTS)
	rm -f $(BUILDDIR)/*/apis* \
		$(BUILDDIR)/*/admin* \
		$(BUILDDIR)/*/overview* \
		$(BUILDDIR)/*/install* \
		$(BUILDDIR)/*/taxonomy*
	tar cf $@ $(BUILDDIR)/*

product-docs-$(VERSION).tar.bz2:
	mkdir -p product-docs-$(VERSION)
	cp -a pdf product-docs-$(VERSION)
	cp -a html product-docs-$(VERSION)
	tar cjf $@ product-docs-$(VERSION)

install: product-docs-$(VERSION).tar.bz2
	cp -r $< $(RPM_BUILD_ROOT)/rpmbuild/SOURCES/

$(RPM_BUILD_ROOT)/rpmbuild:
	mkdir -p $@/BUILD
	mkdir -p $@/BUILDROOT
	mkdir -p $@/RPMS
	mkdir -p $@/SOURCES
	mkdir -p $@/SPECS
	mkdir -p $@/SRPMS
	
package: $(RPM_BUILD_ROOT)/rpmbuild install
	rpmbuild -ba product-docs.spec --define "_topdir $(RPM_BUILD_ROOT)/rpmbuild"
