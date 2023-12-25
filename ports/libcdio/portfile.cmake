vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/ShiftMediaProject/libcdio/archive/refs/tags/release-${VERSION}-2.tar.gz"
    FILENAME "libcdio-release-SMP-${VERSION}.tar.gz"
    SHA512 b2713307b4ad85d88b1ddd3604eb7834d3d0d03c79dc5ab2bc2d7468349bd0df1098d87b9ae97c0eac48aeb9e805ffe5ed0d05a3bb22b8f716047a45e49ce940
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
    0001-Remove-doc-from-config-and-make.patch
    0003-Fix-free-while-still-in-use-in-iso9660.hpp.patch
    0004-src-cdda-player.c-always-use-s-style-format-for-prin.patch
)

if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH SMP/libcdio.sln
    )
else()
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
    )
    vcpkg_install_make()
    vcpkg_fixup_pkgconfig()
endif()


vcpkg_copy_pdbs()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/cdio/cdio_config.h" "${CURRENT_BUILDTREES_DIR}" "")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
