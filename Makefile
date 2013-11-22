# LaTeX Makefile for dvi, ps, and pdf file creation.
# MAGMA - Laboratoire Leibniz 13-12-2004

# The LATEX variable contains the latex command to use, using LATEXFLAGS
# you can specify additional flags to pass. 
LATEX = latex
LATEXFLAGS= -interaction=scrollmode 
PDFLATEX = pdflatex
PDFLATEXFLAGS= 
MAKEINDEX = makeindex

# Specifies the bibliography generation program.
BIBTEX = bibtex
BIBTEXFLAGS=

# These options are used for generating PostScript files from DVI files.
DVIPS = dvips
DVIPSFLAGSPDF = -P pdf
PS2PDF = ps2pdf
PS2PDFFLAGS =

# Commands for images convertion
FIG2DEV = fig2dev
GIFTOPNM = giftopnm
PNMTOPNG = pnmtopng

# Useful commands
EGREP = egrep
ECHO = echo

# The variable USEPDFLATEX must equal 1 to use pdflatex for generating pdf file.
USEPDFLATEX = 1

# Tex directory 
TEX_DIR = tex

# Figures directory for fig to eps or pdf convertion
FIGURE_DIR = figures

# Contain those LaTeX input files which will be passed directly to LaTeX, i.e.
# no include files. 
MAIN_TEX_FILES= $(wildcard *.tex)

# Contains include tex file
TEX_FILES= $(wildcard *.tex) \
	$(wildcard ./$(TEX_DIR)/*.tex)  

# Contains the names of all DVI files to be generated when using the target<.dvi>
# target. Defaults to all files from $(MAIN_TEX_FILES) with their
# extensions changed to target<.dvi>.
DVI_FILES= $(MAIN_TEX_FILES:.tex=.dvi)

# Contains the names of all PostScript resp. PDF files to be generated when
# using the target<.ps> or target<.pdf>.
PS_FILES= $(DVI_FILES:.dvi=.ps)
PDF_FILES= $(DVI_FILES:.dvi=.pdf)

# Contains the names of all eps resp. eps images to be generated when 
# using target<.dvi> or target<.ps> or target<.pdf>.
EPSFIGURES = $(patsubst %.fig,%.eps,$(wildcard ./$(FIGURE_DIR)/*.fig))
PDFFIGURES = $(patsubst %.fig,%.pic,$(wildcard ./$(FIGURE_DIR)/*.fig))

# Target definition

all: $(EPSFIGURES) $(PDFFIGURE)
	$(MAKE) $(DVI_FILES) $(PS_FILES) $(PDF_FILES)

%.dvi %.log %.aux %.toc :  $(EPSFIGURES) $(TEX_FILES)
	$(MAKE) $< 
	@$(ECHO) "----------------------------------------------------------------"
	@$(ECHO) "Running $(LATEX) $* for the first time"
	@$(ECHO) "----------------------------------------------------------------"
	$(LATEX) $(LATEXFLAGS) $* $(LATEXSTDOUT)
#  Path beamer to be sure to have navigation bar
	@if $(EGREP)  "No file .*nav" $*.log && $(EGREP)  "beamer" $*.log; then \
	    $(ECHO) "----------------------------------------------------------------"; \
            $(ECHO) "Running $(LATEX) again to include navigation bar"; \
            $(ECHO) "----------------------------------------------------------------"; \
            $(PDFLATEX) $(PDFLATEXFLAGS) $* $(LATEXSTDOUT); \
        fi; \
#  end beamer
	@if $(EGREP)  "Rerun to get .*references right" $*.log; then \
	  $(ECHO) "----------------------------------------------------------------"; \
          $(ECHO) "Running $(LATEX) again to get references right"; \
          $(ECHO) "----------------------------------------------------------------"; \
	  $(LATEX) $(LATEXFLAGS) $* $(LATEXSTDOUT) ; \
	fi
	@if $(EGREP)  '\\bib(data|cite)' $*.aux; then \
          $(ECHO) "----------------------------------------------------------------"; \
          $(ECHO) "Making Bibliography using $(BIBTEX)"; \
          $(ECHO) "----------------------------------------------------------------"; \
	  $(BIBTEX) $(BIBTEXFLAGS) $*; \
	  if [ -f $*.bbl ]; then \
            $(ECHO) "----------------------------------------------------------------"; \
            $(ECHO) "Running $(LATEX) again to include bibliography"; \
            $(ECHO) "----------------------------------------------------------------"; \
            $(LATEX) $(LATEXFLAGS) $* $(LATEXSTDOUT); \
          fi; \
	fi
	@-count=5; \
	while $(EGREP)  "Rerun to get .*(references|citations) (right|correct)" $*.log && [ $$count -gt 0 ]; do \
           $(ECHO) "----------------------------------------------------------------"; \
           $(ECHO) "Rerunning $(LATEX), max. $$count times left"; \
           $(ECHO) "----------------------------------------------------------------"; \
	   $(LATEX) $(LATEXFLAGS) $* $(LATEXSTDOUT); \
	   count=`expr $$count - 1`; \
	done
# Generate pdf file with pdflatex
ifdef USEPDFLATEX
%.pdf : $(PDFFIGURES) $(TEX_FILES)
	$(MAKE) $<
	@$(ECHO) "----------------------------------------------------------------"
	@$(ECHO) "Running $(PDFLATEX) for the first time..."
	@$(ECHO) "----------------------------------------------------------------"
	$(PDFLATEX) $(PDFLATEXFLAGS) $* $(LATEXSTDOUT)
#  Path beamer to be sure to have navigation bar
	@if $(EGREP)  "No file .*nav" $*.log && $(EGREP)  "beamer" $*.log; then \
	    $(ECHO) "----------------------------------------------------------------"; \
            $(ECHO) "Running $(PDFLATEX) again to include navigation bar"; \
            $(ECHO) "----------------------------------------------------------------"; \
            $(PDFLATEX) $(PDFLATEXFLAGS) $* $(LATEXSTDOUT); \
        fi; \
#  end beamer
	@if $(EGREP)  "Rerun to get .*references right" $*.log; then \
	  $(ECHO) "----------------------------------------------------------------"; \
          $(ECHO) "Running $(PDFLATEX) again to get references right"; \
          $(ECHO) "----------------------------------------------------------------"; \
	  $(PDFLATEX) $(PDFLATEXFLAGS) $* $(LATEXSTDOUT) ; \
	fi
	@if $(EGREP)  '\\bib(data|cite)' $*.aux; then \
          $(ECHO) "----------------------------------------------------------------"; \
          $(ECHO) "Making Bibliography using $(BIBTEX)"; \
          $(ECHO) "----------------------------------------------------------------"; \
	  $(BIBTEX) $(BIBTEXFLAGS) $*; \
	  if [ -f $*.bbl ]; then \
            $(ECHO) "----------------------------------------------------------------"; \
            $(ECHO) "Running $(PDFLATEX) again to include bibliography"; \
            $(ECHO) "----------------------------------------------------------------"; \
            $(PDFLATEX) $(PDFLATEXFLAGS) $* $(LATEXSTDOUT); \
          fi; \
	fi
	@-count=5; \
	while $(EGREP)  "Rerun to get .*(references|citations) (right|correct)" $*.log && [ $$count -gt 0 ]; do \
           $(ECHO) "----------------------------------------------------------------"; \
           $(ECHO) "Rerunning $(PDFLATEX), max. $$count times left"; \
           $(ECHO) "----------------------------------------------------------------"; \
	   $(PDFLATEX) $(PDFLATEXFLAGS) $* $(LATEXSTDOUT); \
	   count=`expr $$count - 1`; \
	done
# Generate pdf file with dvi and dvips
else 
%.pdf : %.ps
	@if [ -s $< ] ; then \
		$(ECHO) "----------------------------------------------------------------"; \
		$(ECHO) "Generating PDF file $@"; \
		$(ECHO) "----------------------------------------------------------------"; \
		$(PS2PDF) $(PS2PDFFLAGS) $< $@; \
	else \
		$(ECHO) "----------------------------------------------------------------"; \
		$(ECHO) "Skipped creating $@: $< does not exist or is empty"; \
		$(ECHO) "----------------------------------------------------------------"; \
	fi
endif

%.ps : %.dvi
	@if [ -s $< ] ; then \
		$(ECHO) "----------------------------------------------------------------"; \
		$(ECHO) "Generating PS file $@"; \
		$(ECHO) "----------------------------------------------------------------"; \
		$(DVIPS) $(DVIPSFLAGSPDF) $< -o  $*.ps ; \
	else \
		$(ECHO) "----------------------------------------------------------------"; \
		$(ECHO) "Skipped creating $@: $< does not exist or is empty"; \
		$(ECHO) "----------------------------------------------------------------"; \
	fi

cleanepsfig:
	-rm -f $(FIGURE_DIR)/*.eps $(FIGURE_DIR)/*.bak

cleanpdffig:
	-rm -f $(FIGURE_DIR)/*.pdf $(FIGURE_DIR)/*.bak

cleanfig: cleanepsfig cleanpdffig

clean: cleanfig
	-rm -f $(TEX_DIR)/*.aux
	-rm -f *.dvi *.ps *.pdf
	-rm -f *.aux *.log *.toc *.out
	-rm -f *.lof *.lot *.loa *.lol
	-rm -f *.nav *.snm *.vrb
	-rm -f *.idx *.ind *.ilg *.glo *.gls *.bbl *.blg
	
cleanlog:
	-rm -f $(TEX_DIR)/*.aux
	-rm -f *.aux *.log *.toc *.out
	-rm -f *.lof *.lot *.loa *.lol
	-rm -f *.nav *.snm *.vrb
	-rm -f *.idx *.ind *.ilg *.glo *.gls *.bbl *.blg

%.eps : %.fig
	@$(ECHO) "----------------------------------------------------------------"
	@$(ECHO) "Convert $*.fig to $*.eps"
	@$(ECHO) "----------------------------------------------------------------"
	$(FIG2DEV) -L eps $*.fig $*.eps

%.pic : %.fig
	@$(ECHO) "----------------------------------------------------------------"
	@$(ECHO) "Convert $*.fig to $*.pdf"
	@$(ECHO) "----------------------------------------------------------------"
	$(FIG2DEV) -L pdf $*.fig  $*.pdf

help:
	@$(ECHO) "Usage: make <target>[.dvi,.ps,.pdf]"
	@$(ECHO) "Options:"
	@$(ECHO) "  - make help	display this message"
	@$(ECHO) "  - make clean remove all intermediate generated file"
	@$(ECHO) "  - make cleanfig remove all intermediate figures"
