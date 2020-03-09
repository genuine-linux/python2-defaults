#!/usr/bin/make -f
INSTALL ?= install
PREFIX ?= /usr/local

clean:
	make -C tests clean
	make -C pydist clean
	find . -name '*.py[co]' -delete
	rm -f .coverage

install:
	$(INSTALL) -m 755 -d $(DESTDIR)$(PREFIX)/bin \
		$(DESTDIR)$(PREFIX)/share/python/runtime.d \
		$(DESTDIR)$(PREFIX)/share/man/man1 \
		$(DESTDIR)$(PREFIX)/share/python \
		$(DESTDIR)$(PREFIX)/lib/valgrind \
		$(DESTDIR)$(PREFIX)/share/python/genpython
	$(INSTALL) -m 755 runtime.d/* $(DESTDIR)$(PREFIX)/share/python/runtime.d/
	$(INSTALL) -m 644 genpython/*.py $(DESTDIR)$(PREFIX)/share/python/genpython/
	$(INSTALL) -m 755 pycompile $(DESTDIR)$(PREFIX)/bin/pycompile
	$(INSTALL) -m 644 pycompile.1 $(DESTDIR)$(PREFIX)/share/man/man1/pycompile.1
	$(INSTALL) -m 755 pyclean $(DESTDIR)$(PREFIX)/bin/pyclean
	$(INSTALL) -m 644 pyclean.1 $(DESTDIR)$(PREFIX)/share/man/man1/pyclean.1
	$(INSTALL) -m 644 genuine_defaults $(DESTDIR)$(PREFIX)/share/python/genuine_defaults
	$(INSTALL) -m 644 python.mk $(DESTDIR)$(PREFIX)/share/python/python.mk
	$(INSTALL) -m 644 pyversions.1 $(DESTDIR)$(PREFIX)/share/man/man1/pyversions.1
	$(INSTALL) -m 755 pyversions.py $(DESTDIR)$(PREFIX)/share/python/pyversions.py
	ln -sfv $(PREFIX)/share/python/pyversions.py $(DESTDIR)$(PREFIX)/bin/pyversions
	$(INSTALL) -m 664 valgrind-python.supp $(DESTDIR)$(PREFIX)/lib/valgrind/python2.supp

check_versions:
	@set -e;\
	DEFAULT=`sed -rn 's,^DEFAULT = \(([0-9]+)\, ([0-9]+)\),\1.\2,p' genpython/version.py`;\
	SUPPORTED=`sed -rn 's,^SUPPORTED = \[\(([0-9]+)\, ([0-9]+)\)\, \(([0-9]+)\, ([0-9]+)\)\],\1.\2 \3.\4,p' genpython/version.py`;\
	GEN_DEFAULT=`sed -rn 's,^default-version = python([0-9.]*),\1,p' genuine/genuine_defaults`;\
	GEN_SUPPORTED=`sed -rn 's|^supported-versions = (.*)|\1|p' genuine/genuine_defaults | sed 's/python//g;s/,//g'`;\
	[ "$$DEFAULT" = "$$GEN_DEFAULT" ] || \
	(echo "Please update DEFAULT in genpython/version.py ($$DEFAULT vs. $$GEN_DEFAULT)" >/dev/stderr; false);\
	[ "$$SUPPORTED" = "$$GEN_SUPPORTED" ] || \
	(echo "Please update SUPPORTED in genpython/version.py ($$SUPPORTED vs. $$GEN_SUPPORTED)" >/dev/stderr; false)

.PHONY: clean check_versions
