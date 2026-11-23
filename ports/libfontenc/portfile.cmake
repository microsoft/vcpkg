if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet!")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

vcpkg_download_distfile(
    LIBFONTENC_ARCHIVE
    URLS "https://www.x.org/archive/individual/lib/libfontenc-${VERSION}.tar.xz"
    FILENAME "libfontenc-${VERSION}.tar.xz"
    SHA512 5908e6a68cdf2af2078454086f408ccff82d08ca7b9a49213d7a1fd6fbd5682742bd000b354e961d1be0654ab73fd59707bdcb4f1b9e19743e2e8fd1b9806e71
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${LIBFONTENC_ARCHIVE}"
    PATCHES
        build.patch
)

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
)

vcpkg_make_install()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
