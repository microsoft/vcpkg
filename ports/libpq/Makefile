subdir = .
top_builddir = .
include src/Makefile.global

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
	$(MAKE) -C src/include
	$(MAKE) -C src/common
	$(MAKE) -C src/port
	$(MAKE) -C src/interfaces/libpq all-$(LIBPQ_LIBRARY_TYPE)-lib
	$(MAKE) -C src/interfaces/ecpg/include
	$(MAKE) -C src/interfaces/ecpg/pgtypeslib
	$(MAKE) -C src/interfaces/ecpg/ecpglib
	$(MAKE) -C src/interfaces/ecpg/compatlib
ifeq ($(LIBPQ_ENABLE_TOOLS), yes)
	$(MAKE) -C src/interfaces/ecpg/preproc
	$(MAKE) -C src/fe_utils
	$(MAKE) -C src/bin
else
	$(MAKE) -C src/bin/pg_config
endif

.PHONY: install-stlib
install-stlib:
	$(MAKE) -C src/common install -o all
	rm -f '$(DESTDIR)$(libdir)/libpgcommon_shlib.a'
	$(MAKE) -C src/port install -o all
	rm -f '$(DESTDIR)$(libdir)/libpgport_shlib.a'

.PHONY: install
install: $(LIBPQ_INSTALL_LIBS)
	$(MAKE) -C src/include install
	$(MAKE) -C src/interfaces/libpq $(EXTRA_TARGET) install-lib-$(LIBPQ_LIBRARY_TYPE) install-lib-pc install -o all -o install-lib
	$(MAKE) -C src/interfaces/ecpg/include install
	$(MAKE) -C src/interfaces/ecpg/pgtypeslib install
	$(MAKE) -C src/interfaces/ecpg/ecpglib install
	$(MAKE) -C src/interfaces/ecpg/compatlib install
ifeq ($(LIBPQ_ENABLE_TOOLS), yes)
	$(MAKE) -C src/interfaces/ecpg/preproc install
	$(MAKE) -C src/bin install
else
	$(MAKE) -C src/bin/pg_config install
endif
