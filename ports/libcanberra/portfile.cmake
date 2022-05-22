set(VERSION 0.30)
set(PATCHES
    pkgconfig.patch
    undefined_reference.diff  # https://sources.debian.org/patches/libcanberra/0.30-7/
    gtk_dont_assume_x11.patch # likewise
    03_onlyshowin_unity.patch # likewise
)

if(VCPKG_TARGET_IS_OSX)
    list(APPEND PATCHES macos_fix.patch)
endif()

if(VCPKG_TARGET_IS_OSX)
    message("${PORT} currently requires the following libraries from the system package manager:\n    automake\n    libtool\n\nThey can be installed with brew install automake libtool")
else()
    message("${PORT} currently requires the following libraries from the system package manager:\n    automake\n    libtool\n\nThey can be installed with apt-get install automake libtool")
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "http://0pointer.de/lennart/projects/${PORT}/${PORT}-${VERSION}.tar.xz"
    FILENAME "${PORT}-${VERSION}.tar.xz"
    SHA512 f7543582122256826cd01d0f5673e1e58d979941a93906400182305463d6166855cb51f35c56d807a56dc20b7a64f7ce4391368d24990c1b70782a7d0b4429c2
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    REF ${VERSION}
    PATCHES ${PATCHES}
)

set(EXTRA_CPPFLAGS)
set(EXTRA_LDFLAGS)

#libltdl fixes
if(VCPKG_TARGET_IS_OSX)
    execute_process(
         COMMAND brew --prefix libtool
         OUTPUT_VARIABLE BREW_LIBTOOL_PATH
    )
    string(STRIP ${BREW_LIBTOOL_PATH} BREW_LIBTOOL_PATH)

    set(LIBS_PRIVATE "-L${BREW_LIBTOOL_PATH}/lib -lltdl")
    set(CFLAGS_PRIVATE "-I${BREW_LIBTOOL_PATH}/include")
    set(EXTRA_LDFLAGS "LDFLAGS=${LIBS_PRIVATE}")
    set(EXTRA_CPPFLAGS "CPPFLAGS=${CFLAGS_PRIVATE}")
else()
    set(LIBS_PRIVATE "-lltdl")
endif()

if (NOT "alsa" IN_LIST FEATURES)
   list(APPEND FEATURES_BACKENDS "--disable-alsa")
endif()
if (NOT "gstreamer" IN_LIST FEATURES)
   list(APPEND FEATURES_BACKENDS "--disable-gstreamer")
endif()
if (NOT "null" IN_LIST FEATURES)
   list(APPEND FEATURES_BACKENDS "--disable-null")
endif()
if (NOT "oss" IN_LIST FEATURES)
   list(APPEND FEATURES_BACKENDS "--disable-oss")
endif()
if (NOT "pulse" IN_LIST FEATURES)
   list(APPEND FEATURES_BACKENDS "--disable-pulse")
endif()


set(ENV{GTKDOCIZE} true)
vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --disable-gtk-doc
        --disable-lynx
        --disable-silent-rules
        --disable-tdb
        ${FEATURES_BACKENDS}
        ${EXTRA_CPPFLAGS}
        ${EXTRA_LDFLAGS}
)

vcpkg_install_make()

configure_file("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${PORT}.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${PORT}.pc" @ONLY)
configure_file("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/${PORT}.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/${PORT}.pc" @ONLY)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools") # empty folder

file(INSTALL "${SOURCE_PATH}/LGPL" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
