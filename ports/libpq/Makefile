subdir = .
top_builddir = .
include src/Makefile.global

.NOTPARALLEL:

ifeq ($(LIBPQ_LIBRARY_TYPE), shared)
LIBPQ_LIB_SUFFIX = _shlib
endif

ifeq ($(LIBPQ_LIBRARY_TYPE), static)
LIBPQ_INSTALL_LIBS = install-stlib
endif

.PHONY: all
all:
	$(MAKE) -C src/include MAKELEVEL=0
	$(MAKE) -C src/common MAKELEVEL=0 libpgcommon$(LIBPQ_LIB_SUFFIX).a
	$(MAKE) -C src/port MAKELEVEL=0 libpgport$(LIBPQ_LIB_SUFFIX).a
	$(MAKE) -C src/interfaces/libpq MAKELEVEL=0 all-$(LIBPQ_LIBRARY_TYPE)-lib
	$(MAKE) -C src/bin/pg_config MAKELEVEL=0

.PHONY: install-stlib
install-stlib:
	$(MAKE) -C src/common MAKELEVEL=0 install -o all
	rm -f '$(DESTDIR)$(libdir)/libpgcommon_shlib.a'
	$(MAKE) -C src/port MAKELEVEL=0 install -o all
	rm -f '$(DESTDIR)$(libdir)/libpgport_shlib.a'

.PHONY: install
install: $(LIBPQ_INSTALL_LIBS)
	$(MAKE) -C src/include MAKELEVEL=0 install
	$(MAKE) -C src/interfaces/libpq MAKELEVEL=0 install-lib-$(LIBPQ_LIBRARY_TYPE) install-lib-pc install -o all -o install-lib
	$(MAKE) -C src/bin/pg_config MAKELEVEL=0 install
