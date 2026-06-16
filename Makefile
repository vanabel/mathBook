.PHONY: all pdf watch live clean distclean zip install install-user help

NAME := mathbook
TEX := main.tex
PDF := $(TEX:.tex=.pdf)
VERSION ?= $(shell git describe --tags --abbrev=0 2>/dev/null || echo v0.0.0)
ZIP := mathbook-$(VERSION).zip

export PATH := $(CURDIR):$(PATH)

UTREE = $(shell kpsewhich -var-value TEXMFHOME)
LOCAL = $(shell kpsewhich -var-value TEXMFLOCAL)
DIR_TEX    = $(LOCAL)/tex/latex/$(NAME)
DIR_SOURCE = $(LOCAL)/source/latex/$(NAME)
DIR_DOC    = $(LOCAL)/doc/latex/$(NAME)
DIR_EXAMPLES = $(DIR_DOC)/examples

LATEXMK = latexmk

all: pdf

help:
	@echo "make        单次编译 $(PDF)"
	@echo "make watch  实时自动编译（latexmk -pvc，保存即增量编译并刷新 PDF）"
	@echo "make live   同 make watch"
	@echo "make clean  清理中间文件"
	@echo "make zip    打包发布"

pdf:
	$(LATEXMK) $(TEX)

watch live:
	@echo ">> 实时编译已开启：保存 .tex 后自动增量编译并刷新 PDF（Ctrl+C 退出）"
	$(LATEXMK) -pvc -view=default $(TEX)

clean:
	latexmk -c $(TEX)
	rm -f *.bcf *.run.xml *.bbl *.blg *.idx *.ilg *.ind

distclean: clean
	latexmk -C $(TEX)
	rm -f $(PDF)

zip: pdf
	$(RM) $(ZIP) mathbook-*.zip
	zip -r $(ZIP) \
		$(PDF) \
		$(TEX) mathbook.sty elegantbook.cls references.bib \
		zh.ist zhmakeindex \
		chapters/ \
		Makefile README.md .gitignore .latexmkrc \
		-x ".git/*" -x "*.zip" -x ".DS_Store"

install: $(NAME).sty elegantbook.cls
	@echo "Installing to $(LOCAL)"
	sudo mkdir -p $(DIR_TEX) $(DIR_SOURCE) $(DIR_DOC) $(DIR_EXAMPLES)
	sudo cp $(NAME).sty elegantbook.cls $(DIR_TEX)/
	sudo cp README.md $(DIR_DOC)/
	sudo cp $(TEX) references.bib zh.ist zhmakeindex Makefile $(DIR_EXAMPLES)/
	sudo cp -r chapters $(DIR_EXAMPLES)/
	sudo mktexlsr

install-user: $(NAME).sty elegantbook.cls
	@echo "Installing to $(UTREE)"
	mkdir -p $(UTREE)/tex/latex/$(NAME) $(UTREE)/source/latex/$(NAME) $(UTREE)/doc/latex/$(NAME) $(UTREE)/doc/latex/$(NAME)/examples
	cp $(NAME).sty elegantbook.cls $(UTREE)/tex/latex/$(NAME)/
	cp README.md $(UTREE)/doc/latex/$(NAME)/
	cp $(TEX) references.bib zh.ist zhmakeindex Makefile $(UTREE)/doc/latex/$(NAME)/examples/
	cp -r chapters $(UTREE)/doc/latex/$(NAME)/examples/
	mktexlsr
