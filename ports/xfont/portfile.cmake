vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libxfont
    REF ed8b8e9fe544ec51ab1b1dfaea6fced35470ad6c # 2.0.4
    SHA512  abea04d57a951434f1cb88005d0651b5cd67ce27c4581e9688c52bbb3a5e7771e0aa9af3a108250e137125b454dbb382b45b8b75d107e7b1eec670ac61a898f2
    HEAD_REF master # branch name
    #PATCHES build.patch #patch name
             #configure.patch
) 

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")
if(VCPKG_TARGET_IS_WINDOWS)
    #set(OPTIONS --enable-ipv6=no)
    string(APPEND VCPKG_CXX_FLAGS " /D_WILLWINSOCK_")
    string(APPEND VCPKG_C_FLAGS " /D_WILLWINSOCK_")
    set(DEPS_DEBUG
                "FREETYPE_LIBS=\"-L${CURRENT_INSTALLED_DIR}/debug/lib/ -lfreetype -lpng16d -lzlib -lbz2d\"")
    set(DEPS_RELEASE
                "FREETYPE_LIBS=\"-L${CURRENT_INSTALLED_DIR}/lib/ -lfreetype -lpng16 -lzlibd -lbz2\"")
else()
    set(DEPS_DEBUG
                "FREETYPE_LIBS=\"-L${CURRENT_INSTALLED_DIR}/debug/lib/ -lfreetype -lpng16d -lz -lbz2d\"")
    set(DEPS_RELEASE
                "FREETYPE_LIBS=\"-L${CURRENT_INSTALLED_DIR}/lib/ -lfreetype -lpng16 -lz -lbz2\"")
endif()
vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    #SKIP_CONFIGURE
    #NO_DEBUG
    #AUTO_HOST
    #AUTO_DST
    #PRERUN_SHELL "export ACLOCAL=\"aclocal -I ${CURRENT_INSTALLED_DIR}/share/xorg-macros/aclocal/\""
    OPTIONS ${OPTIONS}
    OPTIONS_DEBUG ${DEPS_DEBUG}
    OPTIONS_RELEASE ${DEPS_RELEASE}
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Optional Features:
  # --disable-option-checking  ignore unrecognized --enable/--with options
  # --disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=no)
  # --enable-FEATURE[=ARG]  include FEATURE [ARG=yes]
  # --enable-silent-rules   less verbose build output (undo: "make V=1")
  # --disable-silent-rules  verbose build output (undo: "make V=0")
  # --enable-dependency-tracking
                          # do not reject slow dependency extractors
  # --disable-dependency-tracking
                          # speeds up one-time build
  # --enable-shared[=PKGS]  build shared libraries [default=yes]
  # --enable-static[=PKGS]  build static libraries [default=yes]
  # --enable-fast-install[=PKGS]
                          # optimize for fast installation [default=yes]
  # --disable-libtool-lock  avoid locking (might break parallel builds)
  # --disable-selective-werror
                          # Turn off selective compiler errors. (default:
                          # enabled)
  # --enable-strict-compilation
                          # Enable all warnings from compiler and make them
                          # errors (default: disabled)
  # --enable-devel-docs     Enable building the developer documentation
                          # (default: yes)
  # --disable-freetype      Build freetype backend (default: enabled)
  # --disable-builtins      Support builtin fonts (default: enabled)
  # --disable-pcfformat     Support PCF format bitmap fonts (default: enabled)
  # --disable-bdfformat     Support BDF format bitmap fonts (default: enabled)
  # --enable-snfformat      Support SNF format bitmap fonts (default: disabled)
  # --disable-fc            Support connections to xfs servers (default:
                          # enabled)
  # --enable-unix-transport Enable UNIX domain socket transport
  # --enable-tcp-transport  Enable TCP socket transport
  # --enable-ipv6           Enable IPv6 support
  # --enable-local-transport
                          # Enable os-specific local transport

# Optional Packages:
  # --with-PACKAGE[=ARG]    use PACKAGE [ARG=yes]
  # --without-PACKAGE       do not use PACKAGE (same as --with-PACKAGE=no)
  # --with-pic[=PKGS]       try to use only PIC/non-PIC objects [default=use
                          # both]
  # --with-aix-soname=aix|svr4|both
                          # shared library versioning (aka "SONAME") variant to
                          # provide on AIX, [default=aix].
  # --with-gnu-ld           assume the C compiler uses GNU ld [default=no]
  # --with-sysroot[=DIR]    Search for dependent libraries within DIR (or the
                          # compiler's sysroot if not specified).
  # --with-xmlto            Use xmlto to regenerate documentation (default:
                          # auto)
  # --with-fop              Use fop to regenerate documentation (default: auto)
  # --with-freetype-config=PROG
                          # Use FreeType configuration program PROG
  # --with-bzip2            Use libbz2 to support bzip2 compressed bitmap fonts
                          # (default: no)

# Some influential environment variables:
  # CC          C compiler command
  # CFLAGS      C compiler flags
  # LDFLAGS     linker flags, e.g. -L<lib dir> if you have libraries in a
              # nonstandard directory <lib dir>
  # LIBS        libraries to pass to the linker, e.g. -l<library>
  # CPPFLAGS    (Objective) C/C++ preprocessor flags, e.g. -I<include dir> if
              # you have headers in a nonstandard directory <include dir>
  # CPP         C preprocessor
  # LT_SYS_LIBRARY_PATH
              # User-defined run-time library search path.
  # PKG_CONFIG  path to pkg-config utility
  # PKG_CONFIG_PATH
              # directories to add to pkg-config's search path
  # PKG_CONFIG_LIBDIR
              # path overriding pkg-config's built-in search path
  # XMLTO       Path to xmlto command
  # FOP         Path to fop command
  # FREETYPE_CFLAGS
              # C compiler flags for FREETYPE, overriding pkg-config
  # FREETYPE_LIBS
              # linker flags for FREETYPE, overriding pkg-config
  # XFONT_CFLAGS
              # C compiler flags for XFONT, overriding pkg-config
  # XFONT_LIBS  linker flags for XFONT, overriding pkg-config

# Use these variables to override the choices made by `configure' or to help
# it to find libraries and programs with nonstandard names/locations.

# Report bugs to <https://gitlab.freedesktop.org/xorg/lib/libXfont/issues>.
