set(VERSION_MAJOR 2)
set(VERSION_MINOR 37)
set(VERSION_PATCH 2)
set(VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH})

vcpkg_download_distfile(ARCHIVE
    URLS "https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v${VERSION_MAJOR}.${VERSION_MINOR}/util-linux-${VERSION}.tar.xz"
    FILENAME "util-linux-${VERSION}.tar.xz"
    SHA512 38f0fe820445e3bfa79550e6581c230f98c7661566ccc4daa51c7208a5f972c61b4e57dfc86bed074fdbc7c40bc79f856be8f6a05a8860c1c0cecc4208e8b81d
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    REF ${VERSION}
)

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --disable-asciidoc
        --disable-all-programs
        --enable-libmount
        --enable-libblkid
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/sbin" "${CURRENT_PACKAGES_DIR}/debug/sbin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools") # empty folder

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
