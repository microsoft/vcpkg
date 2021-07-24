all: build-gettext-runtime-intl build-gettext-runtime-po build-gettext-runtime-src
all: build-gettext-tools build-gettext-tools-gnulib build-gettext-tools-its build-gettext-tools-m4 build-gettext-tools-misc build-gettext-tools-po build-gettext-tools-projects build-gettext-tools-styles
all: build-libtextstyle

install: install-gettext-runtime-intl install-gettext-runtime-po install-gettext-runtime-src
install: install-gettext-tools install-gettext-tools-gnulib install-gettext-tools-its install-gettext-tools-m4 install-gettext-tools-misc install-gettext-tools-po install-gettext-tools-projects install-gettext-tools-styles
install: install-libtextstyle

build-gettext-runtime-gnulib: build-gettext-runtime-intl
	$(MAKE) -C gettext-runtime/gnulib-lib all
build-gettext-runtime-intl:
	$(MAKE) -C gettext-runtime/intl all
build-gettext-runtime-po:
	$(MAKE) -C gettext-runtime/po all
build-gettext-runtime-src: build-gettext-runtime-intl build-gettext-runtime-gnulib
	$(MAKE) -C gettext-runtime/src all
build-gettext-tools: build-gettext-runtime-intl build-libtextstyle build-gettext-tools-gnulib build-gettext-tools-intl build-gettext-tools-libgrep build-gnulib-local
	$(MAKE) -C gettext-tools/src all
build-gettext-tools-gnulib: build-gettext-tools-intl
	$(MAKE) -C gettext-tools/gnulib-lib all
build-gettext-tools-libgrep: build-gettext-tools-gnulib
	$(MAKE) -C gettext-tools/libgrep all
build-gettext-tools-intl:
	$(MAKE) -C gettext-tools/intl all
build-gettext-tools-its:
	$(MAKE) -C gettext-tools/its all
build-gettext-tools-m4:
	$(MAKE) -C gettext-tools/m4 all
build-gettext-tools-misc:
	$(MAKE) -C gettext-tools/misc all
build-gettext-tools-po:
	$(MAKE) -C gettext-tools/po all
build-gettext-tools-projects:
	$(MAKE) -C gettext-tools/projects all
build-gettext-tools-styles:
	$(MAKE) -C gettext-tools/styles all
build-gnulib-local:
	$(MAKE) -C gnulib-local all
build-libtextstyle:
	$(MAKE) -C libtextstyle/lib all

install-gettext-runtime-intl:
	$(MAKE) -C gettext-runtime/intl install
install-gettext-runtime-po:
	$(MAKE) -C gettext-runtime/po install
install-gettext-runtime-src:
	$(MAKE) -C gettext-runtime/src install
install-gettext-tools:
	$(MAKE) -C gettext-tools/src install
install-gettext-tools-gnulib:
	$(MAKE) -C gettext-tools/gnulib-lib install
install-gettext-tools-its:
	$(MAKE) -C gettext-tools/its install
install-gettext-tools-m4:
	$(MAKE) -C gettext-tools/m4 install
install-gettext-tools-misc:
	$(MAKE) -C gettext-tools/misc install
install-gettext-tools-po:
	$(MAKE) -C gettext-tools/po install
install-gettext-tools-projects:
	$(MAKE) -C gettext-tools/projects install
install-gettext-tools-styles:
	$(MAKE) -C gettext-tools/styles install
install-libtextstyle:
	$(MAKE) -C libtextstyle/lib install
