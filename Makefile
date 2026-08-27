EMACS ?= emacs

.PHONY: tangle check bootstrap doctor clean

tangle:
	$(EMACS) --batch -Q --load scripts/tangle-all.el

check:
	$(EMACS) --batch -Q --load scripts/check.el

bootstrap:
	$(EMACS) --batch -Q --eval "(progn (require 'org) (require 'ob-tangle) (org-babel-tangle-file \"bootstrap.org\"))"
	chmod +x bootstrap.sh

doctor:
	./scripts/doctor.sh

clean:
	rm -f generated/*.el
