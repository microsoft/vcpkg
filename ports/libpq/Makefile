subdir = .
top_builddir = .
include src/Makefile.global

.NOTPARALLEL:

ifeq ($(LIBPQ_LIBRARY_TYPE), static)
LIBPQ_INSTALL_LIBS = install-stlib
endif

ifeq ($(LIBPQ_LIBRARY_TYPE), shared)
ifeq ($(LIBPQ_USING_MINGW), yes)
# The import library name is the same as the static library name
EXTRA_TARGET = install-lib-static
endif
endif

.PHONY: all
all:
	$(MAKE) -C src/include MAKELEVEL=0
	$(MAKE) -C src/common MAKELEVEL=0
	$(MAKE) -C src/port MAKELEVEL=0
	$(MAKE) -C src/interfaces/libpq MAKELEVEL=0 all-$(LIBPQ_LIBRARY_TYPE)-lib
ifeq ($(LIBPQ_ENABLE_TOOLS), yes)
	$(MAKE) -C src/fe_utils MAKELEVEL=0
	$(MAKE) -C src/bin MAKELEVEL=0
else
	$(MAKE) -C src/bin/pg_config MAKELEVEL=0
endif

.PHONY: install-stlib
install-stlib:
	$(MAKE) -C src/common MAKELEVEL=0 install -o all
	rm -f '$(DESTDIR)$(libdir)/libpgcommon_shlib.a'
	$(MAKE) -C src/port MAKELEVEL=0 install -o all
	rm -f '$(DESTDIR)$(libdir)/libpgport_shlib.a'

.PHONY: install
install: $(LIBPQ_INSTALL_LIBS)
	$(MAKE) -C src/include MAKELEVEL=0 install
	$(MAKE) -C src/interfaces/libpq MAKELEVEL=0 $(EXTRA_TARGET) install-lib-$(LIBPQ_LIBRARY_TYPE) install-lib-pc install -o all -o install-lib
ifeq ($(LIBPQ_ENABLE_TOOLS), yes)
	$(MAKE) -C src/bin MAKELEVEL=0 install
else
	$(MAKE) -C src/bin/pg_config MAKELEVEL=0 install
endif
