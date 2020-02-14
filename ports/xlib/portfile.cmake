## requires AUTOCONF, LIBTOOL and PKCONF
message(STATUS "${PORT} requires autoconf, libtool and pkconf from the system package manager!")

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libx11
    REF  db7cca17ad7807e92a928da9d4c68a00f4836da2 #x11 v 1.6.9  
    SHA512 63106422bf74071f73e47a954607472a7df6f4094c197481a100fa10676a22e81ece0459108790d3ebda6a1664c5cba6809bdb80cd5bc4befa1a76bd87188616
    HEAD_REF master # branch name
    PATCHES cl.build.patch #patch name
) 

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

if(VCPKG_TARGET_IS_WINDOWS)
    set(OPTIONS 
        --enable-malloc0returnsnull=yes      #Configre fails to run the test for some reason
        --enable-loadable-i18n=no           #Pointer conversion errors
        --enable-ipv6=no
        --with-launchd=no
        --with-lint=no
        --disable-selective-werror
        --enable-unix-transport=no)
        
        #https://gitlab.freedesktop.org/xorg/xserver/merge_requests/191/diffs
endif()
if(NOT XLSTPROC)
    if(WIN32)
        set(HOST_TRIPLETS x64-windows x64-windows-static x86-windows x86-windows-static)
    elseif(APPLE)
        set(HOST_TRIPLETS x64-osx)
    elseif(UNIX)
        set(HOST_TRIPLETS x64-linux)
    endif()
        foreach(HOST_TRIPLET ${HOST_TRIPLETS})
            find_program(XLSTPROC NAMES xsltproc${VCPKG_HOST_EXECUTABLE_SUFFIX} PATHS "${CURRENT_INSTALLED_DIR}/../${HOST_TRIPLET}/tools/libxslt")
            if(XLSTPROC)
                break()
            endif()
        endforeach()
endif()
if(NOT XLSTPROC)
    message(FATAL_ERROR "${PORT} requires xlstproc for the host system. Please install libxslt within vcpkg or your system package manager!")
endif()
get_filename_component(XLSTPROC_DIR "${XLSTPROC}" DIRECTORY)
file(TO_NATIVE_PATH "${XLSTPROC_DIR}" XLSTPROC_DIR_NATIVE)
vcpkg_add_to_path("${XLSTPROC_DIR}")
set(ENV{XLSTPROC} "${XLSTPROC}")

vcpkg_find_acquire_program(PERL)
vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    #SKIP_CONFIGURE
    #NO_DEBUG
    #AUTO_HOST
    #AUTO_DST
    #PRERUN_SHELL "export ACLOCAL=\"aclocal -I ${CURRENT_INSTALLED_DIR}/share/xorg-macros/aclocal/\""
    OPTIONS ${OPTIONS}
    #OPTIONS_DEBUG
    #OPTIONS_RELEASE
    PKG_CONFIG_PATHS_RELEASE "${CURRENT_INSTALLED_DIR}/lib/pkgconfig"
    PKG_CONFIG_PATHS_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig"
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

if(EXISTS "${CURRENT_INSTALLED_DIR}/include/X11/extensions/XKBgeom.h")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/X11/extensions/") #XKBgeom.h should be the only file in there
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# configure --help
# Optional Features:
  # --disable-option-checking  ignore unrecognized --enable/--with options
  # --disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=no)
  # --enable-FEATURE[=ARG]  include FEATURE [ARG=yes]
  # --enable-dependency-tracking
                          # do not reject slow dependency extractors
  # --disable-dependency-tracking
                          # speeds up one-time build
  # --enable-silent-rules   less verbose build output (undo: "make V=1")
  # --disable-silent-rules  verbose build output (undo: "make V=0")
  # --enable-shared[=PKGS]  build shared libraries [default=yes]
  # --enable-static[=PKGS]  build static libraries [default=yes]
  # --enable-fast-install[=PKGS]
                          # optimize for fast installation [default=yes]
  # --disable-libtool-lock  avoid locking (might break parallel builds)
  # --disable-largefile     omit support for large files
  # --disable-selective-werror
                          # Turn off selective compiler errors. (default:
                          # enabled)
  # --enable-strict-compilation
                          # Enable all warnings from compiler and make them
                          # errors (default: disabled)
  # --enable-specs          Enable building the specs (default: yes)
  # --enable-unix-transport Enable UNIX domain socket transport
  # --enable-tcp-transport  Enable TCP socket transport
  # --enable-ipv6           Enable IPv6 support
  # --enable-local-transport
                          # Enable os-specific local transport
  # --enable-loadable-i18n  Controls loadable i18n module support
  # --disable-loadable-xcursor
                          # Controls loadable xcursor library support
  # --disable-xthreads      Disable Xlib support for Multithreading
  # --disable-xcms          Disable Xlib support for CMS *EXPERIMENTAL*
  # --disable-xlocale       Disable Xlib locale implementation *EXPERIMENTAL*
  # --enable-xlocaledir     Enable XLOCALEDIR environment variable support
  # --disable-xf86bigfont   Disable XF86BigFont extension support
  # --disable-xkb           Disable XKB support *EXPERIMENTAL*
  # --disable-composecache  Disable compose table cache support
  # --enable-lint-library   Create lint library (default: disabled)
  # --enable-malloc0returnsnull
                          # malloc(0) returns NULL (default: auto)

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
  # --with-fop              Use fop to regenerate documentation (default: no)
  # --with-xsltproc         Use xsltproc for the transformation of XML documents
                          # (default: auto)
  # --with-perl             Use perl for extracting information from files
                          # (default: auto)
  # --with-launchd          Build with support for Apple's launchd (default:
                          # auto)
  # --with-keysymdefdir=DIR The location of keysymdef.h (defaults to xproto
                          # include dir)
  # --with-lint             Use a lint-style source code checker (default:
                          # disabled)
  # --with-locale-lib-dir=DIR
                          # Directory where locale libraries files are installed
                          # (default: $libdir/X11/locale)

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
  # XSLTPROC    Path to xsltproc command
  # PERL        Path to perl command
  # BIGFONT_CFLAGS
              # C compiler flags for BIGFONT, overriding pkg-config
  # BIGFONT_LIBS
              # linker flags for BIGFONT, overriding pkg-config
  # LINT        Path to a lint-style command
  # LINT_FLAGS  Flags for the lint-style command
  # X11_CFLAGS  C compiler flags for X11, overriding pkg-config
  # X11_LIBS    linker flags for X11, overriding pkg-config

