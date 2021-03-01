SRC_DIR = chap0 chap1 chap2 chap3 chap4 chap5 chap6 chap7 chap8 chap9 chap10
README = $(patsubst %, %/README.md,$(SRC_DIR))
FILES =	$(patsubst %, doc/%.html,$(SRC_DIR))

NPM_BIN := $(shell npm bin)

all:
	@echo "run 'make install' then 'make dev'"

dev: $(FILES) doc/VPN.html

doc/VPN.html:
	@echo "generating --- $@ from chap10/VPN.md"
	@mkdir -p doc
	@cat .header > doc/VPN.html
	@$(NPM_BIN)/github-markdown -s ../.github-markdown-css/github-markdown.css \
		chap10/VPN.md >> doc/VPN.html
	@cat .footer >> doc/VPN.html

doc/%.html: %/README.md
	@echo "generating ---" $@ "from" $^
	@mkdir -p doc
	@cat .header > $@
	@$(NPM_BIN)/github-markdown -s ../.github-markdown-css/github-markdown.css \
	   $^ >> $@
	@cat .footer >> $@

clean: 
	@rm -f doc/*.html

re: clean dev

install: 
	git submodule init
	git submodule update
	npm install markdown-to-html

watch:
	fswatch -0 chap* | xargs -0 -n1 -I{} make dev
