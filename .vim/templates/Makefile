# Makefile for creating distribution
# Type 'make dist' for create tar-gziped archiv. 

#
# Author: Lubomir Host 'rajo' <host8@kepler.fmph.uniba.sk
#

# $Id$

PACKAGE = test
VERSION = 1.0

DISTFILES = test \
			test/test.c


########################################
# Don't change anything below this line!
# 

#TAR = gtar
TAR = tar
ZIP = zip
ZIP_ENV = -r9
GZIP_ENV = --best


srcdir = .
distdir = $(PACKAGE)-$(VERSION)
top_distdir = $(distdir)
top_builddir = .

dist: distdir
	GZIP=$(GZIP_ENV) $(TAR) chozf $(distdir).tar.gz $(distdir)
	ZIP=$(ZIP_ENV) $(ZIP) $(distdir).zip $(distdir)
	-rm -rf $(distdir)

dist-all: distdir
	GZIP=$(GZIP_ENV) $(TAR) chozf $(distdir).tar.gz $(distdir)
	ZIP=$(ZIP_ENV) $(ZIP) $(distdir).zip $(distdir)
	-rm -rf $(distdir)

distdir: $(DISTFILES)
	-rm -rf $(distdir)
	mkdir $(distdir)
	@here=`cd $(top_builddir) && pwd`; \
	top_distdir=`cd $(distdir) && pwd`; \
	distdir=`cd $(distdir) && pwd`;
	@FILES=`echo "$(DISTFILES)" | awk 'BEGIN{RS=" "}{print}' | sort -u`; \
	for file in $$FILES; do \
	  d=$(srcdir); \
	  if test -d $$d/$$file; then \
	    mkdir $(distdir)/$$file; \
	  else \
	    test -f $(distdir)/$$file \
	    || ln $$d/$$file $(distdir)/$$file 2> /dev/null \
	    || cp -p $$d/$$file $(distdir)/$$file || :; \
	  fi; \
	done


