set(OPENSP_VERSION 1.5.2)

set(PATCHES opensp_1.5.2-13.diff)                   # http://deb.debian.org/debian/pool/main/o/opensp/opensp_1.5.2-13.diff.gz
if (VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_UWP)
    list(APPEND PATCHES windows_cmake_build.diff)   # https://invent.kde.org/packaging/craft-blueprints-kde/-/tree/master/libs/libopensp
endif()
if (VCPKG_TARGET_IS_UWP)
    list(APPEND PATCHES uwp_getenv_fix.diff)
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://downloads.sourceforge.net/project/openjade/opensp/${OPENSP_VERSION}/OpenSP-${OPENSP_VERSION}.tar.gz"
    FILENAME "OpenSP-${OPENSP_VERSION}.tar.gz"
    SHA512 a7dcc246ba7f58969ecd6d107c7b82dede811e65f375b7aa3e683621f2c6ff3e7dccefdd79098fcadad6cca8bb94c2933c63f4701be2c002f9a56f1bbe6b047e
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    REF ${OPENSP_VERSION}
    PATCHES ${PATCHES}
)

if (VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_UWP)
    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
    )

    vcpkg_cmake_install()
else()
    set(EXTRA_OPTS "")
    if(VCPKG_TARGET_IS_OSX)
        list(APPEND EXTRA_OPTS "LDFLAGS=-framework CoreFoundation \$LDFLAGS") # libintl links to it
    endif()

    vcpkg_configure_make(
        AUTOCONFIG
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            --disable-doc-build
            ${EXTRA_OPTS}
    )

    vcpkg_install_make()
endif()

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
