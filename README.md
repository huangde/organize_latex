# My LaTeX template for quick scaffolding and fast start up

LaTeX can be slow to compile, especially for large documents with heavy-duty
packages and complex layouts. Searching online or asking AI for optimization
tips always end up with overwhelming information yet it is unclear which advice is most effective.
For this reason, I conduct a study on multiple strategies to optimize LaTeX compilation, and based on the findings, I have developed this modular template to speed up the document building process.

## The strategies for optimizing LaTeX compilation I have tried
The reason for slow compilation is often the loading of heavy-duty packages.
More specifically, packages that handle figures, bibliographies, and
cross-references tend to increase compilation time significantly. So the first
strategy I tried is to separate the preamble as `draft` and `final` versions,
loading only the necessary packages for `draft` mode, and mock the rest. For example:

```latex
\iffinal
    \usepackage[colorlinks=true,linkcolor=blue,citecolor=blue,urlcolor=blue]{hyperref} % Links in document
  \usepackage[capitalize,noabbrev]{cleveref}
  \Crefname{figure}{Fig.}{Figs.}
  \usepackage[firstinits=true, natbib=true,maxbibnames=99]{biblatex}
  \addbibresource{refs.bib}
  \addbibresource{CoolPropBibTeXLibrary.bib} % CoolProp EOS references
  \DeclareCiteCommand{\bibkeycite}
  {}
  {\printtext[bibhyperref]{\texttt{\thefield{entrykey}}}}
  {\multicitedelim}
  {}
\else
  % Mock hyperref (no-op link commands)
  \providecommand{\href}[2]{#2}
  \providecommand{\url}[1]{\texttt{#1}}
  \providecommand{\hyperlink}[2]{#2}

  % Mock cleveref
  \newcommand{\cref}[1]{Ref.~\ref{#1}}
  \newcommand{\Cref}[1]{Ref.~\ref{#1}}
  \newcommand{\crefrange}[2]{Refs.~\ref{#1}--\ref{#2}}
  \newcommand{\Crefrange}[2]{Refs.~\ref{#1}--\ref{#2}}
  \newcommand{\Crefname}[3]{}

  % Mock biblatex
  \newcommand{\addbibresource}[1]{}
  \newcommand{\bibkeycite}[1]{\texttt{#1}}
  \newcommand{\printbibliography}{%
    \par\bigskip\noindent\textit{[Bibliography omitted in draft mode -- switch to \texttt{\string\finaltrue}]}\par}
  \renewcommand{\cite}[1]{[#1]}
  \newcommand{\textcite}[1]{#1}
\fi

```

In general, I got 3 times faster compilation with the draft mode compared
to the final mode. However, for large document, the speedup may still feel slow
for editing. So the second strategy I tried is to use `\includeonly` to
selectively compile only certain parts of the document, which perform very well.

Later, I tried precompiling the preamble with the $%%&preamble directive, which
allows LaTeX to load a precompiled format file containing the preamble. It seems
to be effective for editing when using with \includeonly, and the compilation
speed difference between draft and final modes becomes less noticeable except
for the initial preamble compilation.

I also tried comparing the VSCode's LaTeX Workshop's default recipe with a self-made makefile, and found that the makefile approach gives slightly slower compilation.

With all these being tested, here I create this latex template for a (I believe) quick scaffolding of LaTeX projects.

The main file for this template is `main.tex` and the preamble is organized into the folder `preamble`, with the following structure:

- `packages.tex` — package imports
- `layout.tex` — page and paragraph layout
- `commands.tex` — reusable commands and environments
- `metadata.tex` — title, author, and date

I keep the following Makefile targets for managing the build process:
- `make` — remove `main.aux`, precompile the selected preamble if needed, and build `main.pdf`
- `make preamble` — remove `main.aux`, then check or rebuild `preamble.fmt`
- `make remove-aux` — remove `main.aux` before a build
- `make clean` — remove auxiliary files while keeping the PDF and format
- `make distclean` — remove all generated build files

A zero-configuration cookie-cutter template is also provided.