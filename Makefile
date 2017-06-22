# Makefile pour la compilation de l'Introduction à Git

#Commandes
PDFLATEX = pdflatex
BIBTEX = bibtex
MAKEGLOSSARIES = makeglossaries
EPSTOPDF = epstopdf
ECHO = echo
DIA = dia

#Répertoires
FIGURE_DIR := figures
CHAPITRE_DIR := chapitres

#Listes de fichiers
FIGURES := $(shell find $(FIGURE_DIR) -type f)
FIGURES := $(wildcard $(FIGURES))
DIA_FIGS :=$(filter %.dia, $(FIGURES))
TARGETPDF := $(subst .dia,.pdf, $(DIA_FIGS))

all: introgit.pdf cleanlog

#Cible de compilation du document en PDF
introgit.pdf : figures *.tex $(CHAPITRE_DIR)/*.tex
	$(PDFLATEX) introgit
	$(BIBTEX) introgit
	$(MAKEGLOSSARIES) introgit
	$(PDFLATEX) introgit

figures: $(TARGETPDF)

$(FIGURE_DIR)/%.pdf : $(FIGURE_DIR)/%.eps
	$(EPSTOPDF) $<

$(FIGURE_DIR)/%.eps : $(FIGURE_DIR)/%.dia
	$(DIA) -e $@ -t eps $<

cleanlog:
	-rm -f $(CHAPITRE_DIR)/*.aux
	-rm -f *.aux *.log *.toc *.out
	-rm -f *.lof *.lot *.loa *.lol
	-rm -f *.nav *.snm *.vrb
	-rm -f *.idx *.ind *.ilg *.glo *.gls *.bbl *.blg

cleanfigpdf:
	-rm -f $(FIGURE_DIR)/*.pdf

cleanfigeps:
	-rm -f $(FIGURE_DIR)/*.eps

cleanfig: cleanfigeps cleanfigpdf

clean: cleanlog cleanfig
	-rm -f introgit.pdf
