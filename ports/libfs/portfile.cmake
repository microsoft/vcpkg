if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet!")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

vcpkg_download_distfile(
    LIBFS_ARCHIVE
    URLS "https://www.x.org/releases/individual/lib/libFS-${VERSION}.tar.xz"
    FILENAME "libFS-${VERSION}.tar.xz"
    SHA512 f4dc361b7e1dcc1f348ea86e96c5a60ff40c5168b6097f00d8a5db2b86d089cfca12ac13dbde5ce3b53279b7eb8773ed6dcd9c678c2e95363ffa5127ecaacee7
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${LIBFS_ARCHIVE}"
)

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
)

vcpkg_make_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
