if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

set(ATKMM_VERSION 2.36.1)

# Keep distfile, don't use GitLab!
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/atkmm/2.36/atkmm-${ATKMM_VERSION}.tar.xz"
    FILENAME "atkmm-${ATKMM_VERSION}.tar.xz"
    SHA512 23c831afac6bb9a0f9f2e622f8f9ffea29445a33b1cd650e0c07ee77e60b28ae5ee978c029e8e0f9b94e9ff4679d69ebde833f15e0a5403d97914cc7ccf98a6a
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dbuild-documentation=false
        -Dbuild-deprecated-api=true # Build deprecated API and include it in the library
        -Dmsvc14x-parallel-installable=false # Use separate DLL and LIB filenames for Visual Studio 2017 and 2019
)
vcpkg_install_meson()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
