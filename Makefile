.DEFAULT_GOAL := all

# Tool names
# MAIN is the root LaTeX file; the PDF, precompiled format, and format log are
# derived from it or named here so the recipes use one consistent configuration.
MAIN ?= main.tex
ETEX ?= etex
LATEXMK ?= latexmk
FORMAT ?= preamble.fmt
PDF ?= $(MAIN:.tex=.pdf)
FORMAT_LOG ?= preamble.log

# These helper values let the REMOVE macro normalize a Make list and turn it
# into the comma-separated path list accepted by PowerShell on Windows.
empty :=
space := $(empty) $(empty)
comma := ,

# List every TeX source under the project so an edit to a chapter or nested
# input file makes the PDF target out of date. Use native recursive listing
# commands because GNU Make's wildcard does not recurse portably on Windows.
ifeq ($(OS),Windows_NT)
TEX_SOURCES := $(shell powershell -NoProfile -Command "Get-ChildItem -Recurse -File -Filter '*.tex' | ForEach-Object { $$_.FullName.Substring((Get-Location).Path.Length + 1).Replace('\','/') }")
# Distclean explicitly removes nested auxiliary files as well as files found
# by latexmk, including any left behind by older builds or included chapters.
SUBFOLDER_AUX_FILES := $(shell powershell -NoProfile -Command "Get-ChildItem -Recurse -File -Filter '*.aux' | ForEach-Object { $$_.FullName.Substring((Get-Location).Path.Length + 1).Replace('\','/') }")
FORMAT_FILES := $(sort $(FORMAT) $(shell powershell -NoProfile -Command "Get-ChildItem -Recurse -File -Filter '*.fmt' | ForEach-Object { $$_.FullName.Substring((Get-Location).Path.Length + 1).Replace('\','/') }"))
else
TEX_SOURCES := $(shell find . -type f -name '*.tex' -print | sed 's|^\./||')
SUBFOLDER_AUX_FILES := $(shell find . -mindepth 2 -type f -name '*.aux' -print | sed 's|^\./||')
FORMAT_FILES := $(sort $(FORMAT) $(shell find . -type f -name '*.fmt' -print | sed 's|^\./||'))
endif
# Every root-level .bib file is a document dependency by default. Set
# BIB_FILES explicitly to select a different bibliography file list.
BIB_FILES ?= $(wildcard *.bib)
# PREAMBLE_SOURCES control when the precompiled format is rebuilt. The PDF
# depends on all TeX sources and bibliographies, not just the preamble inputs.
PREAMBLE_SOURCES := $(MAIN) $(BIB_FILES) $(filter preamble/%,$(TEX_SOURCES))
DOCUMENT_SOURCES := $(sort $(PREAMBLE_SOURCES) $(TEX_SOURCES))
# Files latexmk generates beside MAIN; nested .aux files are collected above
# because they are not all covered by this root-level list.
AUXILIARY_FILES := $(MAIN:.tex=.aux) $(MAIN:.tex=.bbl) $(MAIN:.tex=.bcf) $(MAIN:.tex=.blg) $(MAIN:.tex=.fdb_latexmk) $(MAIN:.tex=.fls) $(MAIN:.tex=.log) $(MAIN:.tex=.out) $(MAIN:.tex=.run.xml) $(MAIN:.tex=.synctex.gz)

# Use platform-specific commands to remove generated files. The Unix version
# accepts the Make list directly; PowerShell expects paths separated by commas.
ifeq ($(OS),Windows_NT)
NULL_DEVICE := NUL
define REMOVE
powershell -NoProfile -Command "Remove-Item -Force -ErrorAction SilentlyContinue -Path $(subst $(space),$(comma),$(strip $(1))); exit 0"
endef
else
NULL_DEVICE := /dev/null
define REMOVE
rm -f $(1)
endef
endif

.PHONY: all build preamble clean distclean help

# The default build first prepares the precompiled format, then creates the PDF.
all: preamble build

# These targets name the main build products and their prerequisites.
build: $(PDF)

preamble: $(FORMAT)

# Compile the preamble into a reusable format. Compiler stdout is hidden to
# keep the terminal concise; the short label indicates this Make-level run.
$(FORMAT): $(PREAMBLE_SOURCES)
	@echo [1] ETEX/pdflatex format run
	@$(ETEX) -ini -interaction=nonstopmode -halt-on-error -jobname=preamble "&pdflatex" mylatexformat.ltx $(MAIN) > $(NULL_DEVICE)

# latexmk runs pdflatex as many times as needed to settle references and the
# bibliography. Silent mode keeps the build output brief while retaining status.
$(PDF): $(FORMAT) $(DOCUMENT_SOURCES)
	@echo [1] LATEXMK build
	@$(LATEXMK) -silent -pdf -interaction=nonstopmode -file-line-error -synctex=1 $(MAIN)

# Remove ordinary intermediate files but keep the PDF and precompiled format.
clean:
	-@$(LATEXMK) -silent -c $(MAIN) > $(NULL_DEVICE)
	@$(call REMOVE,$(AUXILIARY_FILES) $(FORMAT_LOG))

# Remove all build products, including the PDF, format, and any
# nested .aux files that may not have been removed by latexmk itself.
distclean:
	-@$(LATEXMK) -silent -C $(MAIN) > $(NULL_DEVICE)
	@$(call REMOVE,$(PDF) $(FORMAT_FILES) $(FORMAT_LOG) $(AUXILIARY_FILES) $(SUBFOLDER_AUX_FILES))

# Show the common targets and the files each cleanup target preserves/removes.
help:
	@echo make              Build $(PDF) using the existing auxiliary files
	@echo make preamble     Rebuild the precompiled LaTeX format
	@echo make clean        Remove auxiliary files and keep the PDF and format
	@echo make distclean    Remove all generated build files
