ISSO_JS_SRC := $(shell find isso/js/app -type f) $(shell ls isso/js/*.js | grep -vE "(min|dev)")
ISSO_JS_DST := isso/js/embed.min.js isso/js/embed.dev.js isso/js/count.min.js isso/js/count.dev.js

ISSO_CSS := isso/css/isso.css

ISSO_PY_SRC := $(shell git ls-files | grep .py)

RST := $(shell find docs/ -type f -name  '*.rst')
MAN := man/man1/isso.1 man/man5/isso.conf.5

WWW := docs/index.html share/isso.conf $(wildcard docs/_static/*)
CSS := docs/_static/css/site.css

all: man js site

init:
	(cd isso/js; bower install almond requirejs requirejs-text)

isso/js/%.min.js: $(ISSO_JS_SRC) $(ISSO_CSS)
	r.js -o isso/js/build.$*.js out=$@

isso/js/%.dev.js: $(ISSO_JS_SRC) $(ISSO_CSS)
	r.js -o isso/js/build.$*.js optimize="none" out=$@

js: $(ISSO_JS_DST)

man: $(RST)
	sphinx-build -b man docs/ man/
	mv man/isso.1 man/man1/isso.1
	mv man/isso.conf.5 man/man5/isso.conf.5

${CSS}: docs/_static/css/site.scss
	scss --no-cache $< $@

site: $(RST) $(WWW) $(CSS)
	cd docs && sphinx-build -b dirhtml . _build/html

coverage: $(ISSO_PY_SRC)
	nosetests --with-doctest --with-coverage --cover-package=isso --cover-html isso/

test: $($ISSO_PY_SRC)
	python setup.py nosetests

clean:
	rm -f $(MAN) $(CSS) $(ISSO_JS_DST)

.PHONY: clean site man init js coverage test

