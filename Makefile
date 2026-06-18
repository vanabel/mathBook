.PHONY: all pdf watch live clean distclean zip install install-user help minted-setup

NAME := mathbook

# Entry .tex file (override: make MAIN=book.tex  or  put MAIN=... in Makefile.local)
-include Makefile.local
MAIN ?= main.tex
PDF := $(MAIN:.tex=.pdf)
JOB := $(basename $(MAIN))
VERSION ?= $(shell git describe --tags --abbrev=0 2>/dev/null || echo v0.0.0)
ZIP := mathbook-$(VERSION).zip

# Prefer system zhmakeindex; bundled ./zhmakeindex is fallback only (may SIGSEGV on Apple Silicon).
ZHMAKEINDEX ?= $(shell command -v zhmakeindex 2>/dev/null)
ifeq ($(ZHMAKEINDEX),)
  ZHMAKEINDEX := $(CURDIR)/zhmakeindex
endif
export ZHMAKEINDEX

# TeX bin first (latexminted for minted v3); do not prepend $(CURDIR) — breaks zhmakeindex on ARM.
TEXBIN := $(dir $(abspath $(shell command -v kpsewhich 2>/dev/null)))
export PATH := $(TEXBIN)$(PATH)

UTREE = $(shell kpsewhich -var-value TEXMFHOME)
LOCAL = $(shell kpsewhich -var-value TEXMFLOCAL)
DIR_TEX    = $(LOCAL)/tex/latex/$(NAME)
DIR_SOURCE = $(LOCAL)/source/latex/$(NAME)
DIR_DOC    = $(LOCAL)/doc/latex/$(NAME)
DIR_EXAMPLES = $(DIR_DOC)/examples

LATEXMK = latexmk -xelatex

all: pdf

help:
	@echo "入口文件: $(MAIN)  (覆盖: make MAIN=book.tex 或 Makefile.local)"
	@echo "make        单次编译 $(PDF)"
	@echo "make watch  实时自动编译（latexmk -pvc，保存即增量编译并刷新 PDF）"
	@echo "make live   同 make watch"
	@echo "make clean  清理中间文件"
	@echo "make minted-setup  一次性配置 Wolfram 代码高亮（latexminted 自定义词法器）"
	@echo "make zip    打包发布"

# Wolfram minted lexer: whitelist wolfram_lexer.py in TEXMFHOME/.latexminted_config
TEXMF_HOME := $(shell kpsewhich -var-value TEXMFHOME 2>/dev/null)
TEXMF_HOME := $(if $(TEXMF_HOME),$(TEXMF_HOME),$(HOME)/texmf)
WOLFRAM_LEXER := pygments/wolfram_lexer.py
WOLFRAM_LEXER_HASH := $(shell shasum -a 256 $(WOLFRAM_LEXER) 2>/dev/null | awk '{print $$1}')

minted-setup:
	@mkdir -p $(TEXMF_HOME)
	@printf '%s\n' '{' \
	  '  "custom_lexers": {' \
	  '    "wolfram_lexer.py": "$(WOLFRAM_LEXER_HASH)"' \
	  '  }' \
	  '}' > $(TEXMF_HOME)/.latexminted_config
	@cp $(TEXMF_HOME)/.latexminted_config .latexminted.config.example
	@echo ">> wrote $(TEXMF_HOME)/.latexminted_config"
	@echo ">> updated .latexminted.config.example"
	@echo ">> wolfram_lexer.py SHA-256: $(WOLFRAM_LEXER_HASH)"
	@echo ">> 在本项目目录执行 make pdf；Wolfram 示例使用 \\begin{wolfram} 环境"

pdf:
	@echo ">> zhmakeindex: $(ZHMAKEINDEX)"
	@echo ">> TeX bin:     $(TEXBIN)"
	$(LATEXMK) $(MAIN)

watch live:
	@echo ">> zhmakeindex: $(ZHMAKEINDEX)"
	@echo ">> 实时编译已开启：保存 .tex 后自动增量编译并刷新 PDF（Ctrl+C 退出）"
	$(LATEXMK) -pvc -view=pdf $(MAIN)

clean:
	latexmk -c $(MAIN)
	rm -f $(JOB).bcf $(JOB).run.xml $(JOB).bbl $(JOB).blg $(JOB).idx $(JOB).ilg $(JOB).ind
	rm -rf _minted _minted-$(JOB)
	rm -f _*.message.minted
	find pygments -type d -name __pycache__ -prune -exec rm -rf {} + 2>/dev/null || true

distclean: clean
	latexmk -C $(MAIN)
	rm -f $(PDF)

zip: pdf
	$(RM) $(ZIP) mathbook-*.zip
	zip -r $(ZIP) \
		$(PDF) \
		$(MAIN) mathbook.sty elegantbook.cls references.bib \
		zh.ist zhmakeindex \
		chapters/ metapost/ pygments/ docs/ \
		.latexminted.config.example \
		Makefile README.md .gitignore .latexmkrc \
		-x ".git/*" -x "*.zip" -x ".DS_Store"

install: $(NAME).sty elegantbook.cls
	@echo "Installing to $(LOCAL)"
	sudo mkdir -p $(DIR_TEX) $(DIR_SOURCE) $(DIR_DOC) $(DIR_EXAMPLES)
	sudo cp $(NAME).sty elegantbook.cls $(DIR_TEX)/
	sudo cp README.md $(DIR_DOC)/
	sudo cp $(MAIN) references.bib zh.ist zhmakeindex Makefile $(DIR_EXAMPLES)/
	sudo cp -r chapters $(DIR_EXAMPLES)/
	sudo mktexlsr

install-user: $(NAME).sty elegantbook.cls
	@echo "Installing to $(UTREE)"
	mkdir -p $(UTREE)/tex/latex/$(NAME) $(UTREE)/source/latex/$(NAME) $(UTREE)/doc/latex/$(NAME) $(UTREE)/doc/latex/$(NAME)/examples
	cp $(NAME).sty elegantbook.cls $(UTREE)/tex/latex/$(NAME)/
	cp README.md $(UTREE)/doc/latex/$(NAME)/
	cp $(MAIN) references.bib zh.ist zhmakeindex Makefile $(UTREE)/doc/latex/$(NAME)/examples/
	cp -r chapters $(UTREE)/doc/latex/$(NAME)/examples/
	mktexlsr
