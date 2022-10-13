set(VERSION 0.30)

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
    PATCHES
        ltdl-dlopen.patch
        03_onlyshowin_unity.patch
)

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

vcpkg_list(SET options)
if(VCPKG_TARGET_IS_OSX)
    vcpkg_list(APPEND options
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
        --disable-gtk3
        --disable-gtk-doc
        --disable-lynx
        --disable-silent-rules
        --disable-tdb
        --disable-udev
        ${FEATURES_BACKENDS}

)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools") # empty folder

file(INSTALL "${SOURCE_PATH}/LGPL" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
