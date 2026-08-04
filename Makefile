EMACS ?= emacs

.PHONY: tangle check bootstrap doctor clean book

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
	rm -f book/*.aux book/*.bbl book/*.bcf book/*.blg book/*.fdb_latexmk
	rm -f book/*.fls book/*.log book/*.out book/*.run.xml book/*.tex book/*.toc

book:
	$(EMACS) --batch -Q \
	  --eval "(progn (require 'org) (require 'ox-latex) (find-file \"book/book.org\") (org-latex-export-to-pdf))"
