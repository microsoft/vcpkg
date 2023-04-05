# The steps represent SUBDIRS from Makefile.am/.in, recursively, but
# omit "gettext-runtime/intl" (provided by gettext-libintl or system),
# doc, tests, examples, maintainer stuff, java, csharp, libasprintf.
# "gettext-tools/src libtextstyle.h" is needed to fix parallel build.
STEPS := \
    "gettext-runtime/gnulib-lib all" \
	"gettext-runtime/src all" \
	"gettext-runtime/po all" \
	"gettext-runtime all-am" \
	"libtextstyle/lib all" \
	"gettext-tools/intl all" \
	"gettext-tools/gnulib-lib all" \
	"gettext-tools/libgrep all" \
	"gettext-tools/src textstyle.h" \
	"gettext-tools/src all" \
	"gettext-tools/po all" \
	"gettext-tools/its all" \
	"gettext-tools/projects all" \
	"gettext-tools/styles all" \
	"gettext-tools/misc all" \
	"gettext-tools all-am"

INSTALL_STEPS := $(patsubst all%,install%,$(STEPS))

.PHONY: all install

all:
	rm -f failed; for I in $(STEPS); do $(MAKE) -C $$I || { touch failed ; break ; } ; done | ts ; test ! -f failed

install:
	rm -f failed; for I in $(INSTALL_STEPS); do $(MAKE) -C $$I || { touch failed ; break ; } ; done | ts ; test ! -f failed

