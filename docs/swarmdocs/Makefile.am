BOOKS = refbook installbook overbook set @JAVADOCDIR@
SUBDIRS = figs $(BOOKS) m4 tex
EXTRA_DIST = Makefile.common Makefile.rules history.el common.dsl html.dsl print.dsl global.ent docbook.dcl

all-recursive-am: versions.ent

noinst_DATA = versions.ent

.PHONY: FORCE html dvi rtf fot ps htmldist dvidist rtfdist psdist alldist

alldist: htmldist dvidist rtfdist psdist

html dvi rtf fot ps htmldist dvidist rtfdist psdist: versions.ent
	for dir in $(BOOKS) ; do \
	  $(MAKE) -C $$dir $@; done		

versions.ent: FORCE
	((echo '<!ENTITY swarm-release-number "' ; head -1 $(swarm_srcdir)/VERSION ; echo '">') | tr -d '\n' ; echo) > versions.ent.new
	echo '<!ENTITY swarm-doc-release-number "@VERSION@">' >> versions.ent.new
	((echo '<!ENTITY pubdate "' ; date +'%d %B %Y' ; echo '">') | tr -d '\n' ; echo) >> versions.ent.new
	@if test -f versions.ent; then \
	  if cmp versions.ent versions.ent.new; then \
	    echo No change, using old version.ent; \
	    $(RM) versions.ent.new; \
	  else \
	    echo Different content, using new version; \
	    mv versions.ent.new versions.ent; \
	  fi \
	else \
	  echo Using versions.ent.new; \
	  mv versions.ent.new versions.ent; \
	fi