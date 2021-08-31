set(VERSION 0.30)
set(PATCHES)

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

#libltdl fixes
if(VCPKG_TARGET_IS_OSX)
    execute_process(
         COMMAND brew --prefix libtool
         OUTPUT_VARIABLE BREW_LIBTOOL_PATH
    )
    string(STRIP ${BREW_LIBTOOL_PATH} BREW_LIBTOOL_PATH)

    set(EXTRA_LDFLAGS "LDFLAGS=-L${BREW_LIBTOOL_PATH}/lib/")
    set(EXTRA_CPPFLAGS "CPPFLAGS=-I${BREW_LIBTOOL_PATH}/include/")
else()
    set(EXTRA_CPPFLAGS)
    set(EXTRA_LDFLAGS)
endif()

set(ENV{GTKDOCIZE} true)
vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --disable-gtk-doc
        --disable-lynx
        --disable-silent-rules
        ${EXTRA_CPPFLAGS}
        ${EXTRA_LDFLAGS}
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools") # empty folder

file(INSTALL "${SOURCE_PATH}/LGPL" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
