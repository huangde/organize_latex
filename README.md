# Modular LaTeX sample

This example keeps `main.tex` focused on the document and selects one complete
preamble set based on the `\ifdraft` switch. Each mode has four files under
`preamble/draft/` or `preamble/final/`:

- `packages.tex` — package imports
- `layout.tex` — page and paragraph layout
- `commands.tex` — reusable commands and environments
- `metadata.tex` — title, author, and date

Set `\drafttrue` in `main.tex` to use the draft set or `\draftfalse` to use
the final set. The two sets currently start from the same setup and can be
customized independently.

The draft package set omits hyperlink and bibliography packages. Its command
stubs replace common biblatex, cleveref, hyperref, minted, and listings calls
with lightweight placeholders; `graphicx` uses its draft option to skip image
rendering. For large TikZ or PGFPlots environments, conditionally omit the
entire environment in draft mode rather than loading those packages there.

Toggle `\drafttrue` and `\draftfalse` in `main.tex` to compare the lightweight
draft stubs with the real biblatex, cleveref, and TikZ packages. The Makefile
keeps that switch as the source of truth and precompiles the selected preamble
before building the document.

GNU Make and the MiKTeX commands `etex`, `pdflatex`, `latexmk`, and `biber` must
be available on `PATH`. From the project directory, use:

- `make` — remove `main.aux`, precompile the selected preamble if needed, and build `main.pdf`
- `make preamble` — remove `main.aux`, then check or rebuild `preamble.fmt`
- `make remove-aux` — remove `main.aux` before a build
- `make clean` — remove auxiliary files while keeping the PDF and format
- `make distclean` — remove all generated build files

When the final mode is selected, `latexmk` detects the `biblatex` control file
and runs Biber automatically. Make does not rewrite the mode switch, so change
`main.tex` explicitly before building the other mode.
