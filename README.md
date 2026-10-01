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
draft stubs with the real biblatex, cleveref, and TikZ packages. Build each mode
with a separate job name so their auxiliary files do not conflict:

- Draft: `latexmk -pdf -jobname=main-draft main.tex`
- Final: `latexmk -pdf -jobname=main-final main.tex` (with `\draftfalse`)

The final build also runs Biber. For cold-build timings, clear that mode's
outputs first with `latexmk -C -jobname=main-draft` or
`latexmk -C -jobname=main-final`, then run its build command above. This keeps
the two modes' auxiliary files isolated.
