.PHONY: all pdf terminology watch live stop clean distclean zip install install-user help minted-setup

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

# TeX bin (latexminted for minted v3): resolve xelatex/xetex via command -v + abs_path.
TEXBIN := $(shell perl -MCwd=abs_path -e 'for (qw(xelatex xetex)) { my $$p=`command -v $$_ 2>/dev/null`; chomp $$p; next unless $$p && -x $$p; $$p=abs_path($$p); if ($$p =~ m{^(.*)/(xelatex|xetex)$$}) { print $$1; last } }')
# latexminted 0.6.x + Python 3.14: prepend scripts/shim/python3 (before TEX bin).
MINTED_SHIM_PREFIX := $(shell perl -MCwd=abs_path -e 'my $$s=abs_path("scripts/shim"); -d $$s && -x "$$s/python3" or exit; system("python3","-c","import sys; sys.exit(0 if sys.version_info[:2]>=(3,14) else 1)")==0 or exit; print "$$s:"')
ifneq ($(TEXBIN),)
export SELFAUTOLOC := $(TEXBIN)
endif
export PATH := $(MINTED_SHIM_PREFIX)$(if $(TEXBIN),$(TEXBIN):,)$(PATH)
export TEXMF_OUTPUT_DIRECTORY := $(CURDIR)

UTREE = $(shell kpsewhich -var-value TEXMFHOME)
LOCAL = $(shell kpsewhich -var-value TEXMFLOCAL)
DIR_TEX    = $(LOCAL)/tex/latex/$(NAME)
DIR_SOURCE = $(LOCAL)/source/latex/$(NAME)
DIR_DOC    = $(LOCAL)/doc/latex/$(NAME)
DIR_EXAMPLES = $(DIR_DOC)/examples

LATEXMK = latexmk -pdf

all: pdf

help:
	@echo "入口文件: $(MAIN)  (覆盖: make MAIN=book.tex 或 Makefile.local)"
	@echo "make        单次编译 $(PDF)"
	@echo "make terminology  从 TERMINOLOGY.md 生成中英文术语对照表"
	@echo "make watch  实时自动编译（latexmk -pvc，保存即增量编译并刷新 PDF）"
	@echo "make live   同 make watch"
	@echo "make stop   结束本项目相关的 latexmk/xelatex/biber 等编译进程"
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

terminology:
	node tools/generate-terminology-glossary.mjs

watch live:
	@echo ">> zhmakeindex: $(ZHMAKEINDEX)"
	@echo ">> 实时编译已开启：保存 .tex 后自动增量编译并刷新 PDF（Ctrl+C 退出）"
	$(LATEXMK) -pvc -view=pdf $(MAIN)

# Stop this project's latexmk/xelatex/biber/... (and make watch/live/pdf in this cwd).
# Scoped by CURDIR / MAIN / JOB so other TeX projects are left alone.
stop:
	@echo ">> stopping LaTeX build for $(MAIN) in $(CURDIR)"
	@perl -e ' \
	  use strict; use warnings; \
	  my $$dir  = q($(CURDIR)); \
	  my $$main = q($(MAIN)); \
	  my $$job  = q($(JOB)); \
	  my $$self = $$$$; \
	  my $$tool_tok = qr{(?:^|\s)(?:\S*/)?(?:latexmk|xelatex|xetex|pdflatex|lualatex|biber|bibtex|zhmakeindex|makeindex|mpost|latexminted)(?:\s|$$)}; \
	  my $$shell = qr{(?:^|/)(?:zsh|bash|sh|dash|fish|csh|tcsh)(?:\s|$$)}; \
	  my %want; \
	  open my $$ps, "-|", "ps", "-axo", "pid=,args=" or die $$!; \
	  while (<$$ps>) { \
	    chomp; \
	    next unless /^\s*(\d+)\s+(.*)\z/; \
	    my ($$pid, $$args) = ($$1 + 0, $$2); \
	    next if $$pid == $$self; \
	    next if $$args =~ $$shell; \
	    next unless $$args =~ $$tool_tok; \
	    next unless index($$args, $$dir) >= 0 \
	             || index($$args, $$main) >= 0 \
	             || $$args =~ /(?:^|\s|\/)\Q$$job\E\.(?:tex|bcf|idx|ind|ilg|mp|aux|fls|fdb_latexmk)\b/; \
	    $$want{$$pid} = $$args; \
	  } \
	  close $$ps; \
	  for my $$pid (split /\n/, qx(pgrep -x make 2>/dev/null)) { \
	    $$pid += 0; \
	    next unless $$pid; \
	    next if $$pid == $$self; \
	    my $$cwd = qx(lsof -a -p $$pid -d cwd -Fn 2>/dev/null); \
	    next unless $$cwd =~ /^n\Q$$dir\E\s*\z/m; \
	    my $$args = qx(ps -p $$pid -o args= 2>/dev/null); \
	    chomp $$args; \
	    next unless $$args =~ /(?:^|\s)(?:watch|live|pdf)(?:\s|$$)/; \
	    $$want{$$pid} = $$args; \
	  } \
	  unless (%want) { print ">> no matching processes\n"; exit 0; } \
	  for my $$pid (sort { $$a <=> $$b } keys %want) { \
	    print "   TERM $$pid  $$want{$$pid}\n"; \
	    kill "TERM", $$pid; \
	  } \
	  select undef, undef, undef, 0.4; \
	  for my $$pid (keys %want) { \
	    next unless kill 0, $$pid; \
	    my $$args = qx(ps -p $$pid -o args= 2>/dev/null); \
	    chomp $$args; \
	    print "   KILL $$pid  $$args\n"; \
	    kill "KILL", $$pid; \
	  } \
	  print ">> stopped\n"; \
	'

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
		TERMINOLOGY.md \
		zh.ist zhmakeindex \
		chapters/ metapost/ pygments/ docs/ scripts/ tools/ \
		.latexminted.config.example \
		Makefile README.md .gitignore .latexmkrc \
		-x ".git/*" -x "*.zip" -x ".DS_Store"

install: $(NAME).sty elegantbook.cls
	@echo "Installing to $(LOCAL)"
	sudo mkdir -p $(DIR_TEX) $(DIR_SOURCE) $(DIR_DOC) $(DIR_EXAMPLES)
	sudo cp $(NAME).sty elegantbook.cls $(DIR_TEX)/
	sudo cp README.md TERMINOLOGY.md $(DIR_DOC)/
	sudo cp $(MAIN) references.bib zh.ist zhmakeindex Makefile $(DIR_EXAMPLES)/
	sudo cp -r chapters tools $(DIR_EXAMPLES)/
	sudo mktexlsr

install-user: $(NAME).sty elegantbook.cls
	@echo "Installing to $(UTREE)"
	mkdir -p $(UTREE)/tex/latex/$(NAME) $(UTREE)/source/latex/$(NAME) $(UTREE)/doc/latex/$(NAME) $(UTREE)/doc/latex/$(NAME)/examples
	cp $(NAME).sty elegantbook.cls $(UTREE)/tex/latex/$(NAME)/
	cp README.md TERMINOLOGY.md $(UTREE)/doc/latex/$(NAME)/
	cp $(MAIN) references.bib zh.ist zhmakeindex Makefile $(UTREE)/doc/latex/$(NAME)/examples/
	cp -r chapters tools $(UTREE)/doc/latex/$(NAME)/examples/
	mktexlsr
