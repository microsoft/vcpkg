vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}
if(VCPKG_TARGET_IS_OSX)
    message("${PORT} currently requires the following libraries from the system package manager:\n    automake\n    libtool\n\nThey can be installed with brew install automake libtool")
else()
    message("${PORT} currently requires the following libraries from the system package manager:\n    automake\n    libtool\n    ltdl-dev\n\nThey can be installed with apt-get install automake libtool ltdl-dev")
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "http://0pointer.de/lennart/projects/${PORT}/${PORT}-${VERSION}.tar.xz"
    FILENAME "${PORT}-${VERSION}.tar.xz"
    SHA512 f7543582122256826cd01d0f5673e1e58d979941a93906400182305463d6166855cb51f35c56d807a56dc20b7a64f7ce4391368d24990c1b70782a7d0b4429c2
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        ltdl.patch
        undefined_reference.diff  # https://sources.debian.org/patches/libcanberra/0.30-7/
        gtk_dont_assume_x11.patch # likewise
        03_onlyshowin_unity.patch # likewise
        lc-messages.patch
)

foreach(backend in oss pulse)
    if("${backend}" IN_LIST FEATURES)
        message(STATUS "Backend '${backend}' requires system libraries")
    endif()
endforeach()

vcpkg_list(SET OPTIONS)
foreach(feature IN ITEMS alsa gstreamer gtk3 null oss pulse)
    if("${feature}" IN_LIST FEATURES)
        list(APPEND OPTIONS "--enable-${feature}")
    else()
        list(APPEND OPTIONS "--disable-${feature}")
    endif()
endforeach()

if(VCPKG_TARGET_IS_OSX)
    execute_process(
         COMMAND brew --prefix libtool
         OUTPUT_VARIABLE BREW_LIBTOOL_PATH
         OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    vcpkg_list(APPEND OPTIONS
        "CPPFLAGS=-I${BREW_LIBTOOL_PATH}/include"
        "LTDL_LDFLAGS=-L${BREW_LIBTOOL_PATH}/lib"
        cc_cv_LDFLAGS__Wl___as_needed=no
        cc_cv_LDFLAGS__Wl___gc_sections=no
    )
endif()

set(ENV{GTKDOCIZE} true)
vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --disable-gtk
        --disable-gtk-doc
        --disable-lynx
        --disable-silent-rules
        --disable-tdb
        --disable-udev
        ${OPTIONS}
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools") # empty folder

file(INSTALL "${SOURCE_PATH}/LGPL" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
