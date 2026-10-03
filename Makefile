.DEFAULT_GOAL := all

ETEX ?= etex
LATEXMK ?= latexmk
MAIN ?= main.tex
FORMAT ?= preamble.fmt
PDF ?= $(MAIN:.tex=.pdf)
FORMAT_LOG ?= preamble.log

ifeq ($(OS),Windows_NT)
MODE := $(strip $(shell powershell -NoProfile -Command "if (Select-String -Path '$(MAIN)' -Pattern '^\s*\\drafttrue(\s|%|$$)' -Quiet) { 'draft' } else { 'final' }"))
else
MODE := $(strip $(shell if grep -Eq '^\s*\\drafttrue(\s|%|$$)' $(MAIN); then printf draft; else printf final; fi))
endif

MODE_MARKER := .latex-mode-$(MODE)
MODE_MARKERS := .latex-mode-draft .latex-mode-final

empty :=
space := $(empty) $(empty)
comma := ,

PREAMBLE_SOURCES := $(MAIN) references.bib $(wildcard preamble/draft/*.tex) $(wildcard preamble/final/*.tex)
DOCUMENT_SOURCES := $(PREAMBLE_SOURCES)
AUXILIARY_FILES := $(MAIN:.tex=.aux) $(MAIN:.tex=.bbl) $(MAIN:.tex=.bcf) $(MAIN:.tex=.blg) $(MAIN:.tex=.fdb_latexmk) $(MAIN:.tex=.fls) $(MAIN:.tex=.log) $(MAIN:.tex=.out) $(MAIN:.tex=.run.xml) $(MAIN:.tex=.synctex.gz)

ifeq ($(OS),Windows_NT)
define REMOVE
powershell -NoProfile -Command "Remove-Item -Force -ErrorAction SilentlyContinue -Path $(subst $(space),$(comma),$(1)); exit 0"
endef
else
define REMOVE
rm -f $(1)
endef
endif

.PHONY: all build preamble clean distclean help

all: preamble build

build: $(PDF)

preamble: $(FORMAT)

$(MODE_MARKER):
	$(call REMOVE,$(filter-out $(MODE_MARKER),$(MODE_MARKERS)) $(PDF) $(FORMAT) $(FORMAT_LOG) $(AUXILIARY_FILES))
	@echo $(MODE) > $@

$(FORMAT): $(MODE_MARKER) $(PREAMBLE_SOURCES)
	$(ETEX) -ini -interaction=nonstopmode -halt-on-error -jobname=preamble "&pdflatex" mylatexformat.ltx $(MAIN)

$(PDF): $(MODE_MARKER) $(FORMAT) $(DOCUMENT_SOURCES)
	$(LATEXMK) -pdf -interaction=nonstopmode -file-line-error -synctex=1 $(MAIN)

clean:
	-$(LATEXMK) -c $(MAIN)
	$(call REMOVE,$(AUXILIARY_FILES) $(FORMAT_LOG))

distclean:
	-$(LATEXMK) -C $(MAIN)
	$(call REMOVE,$(PDF) $(FORMAT) $(FORMAT_LOG) $(AUXILIARY_FILES) $(MODE_MARKERS) main-draft.* main-final.*)

help:
	@echo make              Build $(PDF) using the existing auxiliary files
	@echo make preamble     Rebuild the precompiled LaTeX format
	@echo make clean        Remove auxiliary files and keep the PDF and format
	@echo make distclean    Remove all generated build files
