vcpkg_download_distfile(ARCHIVE
    URLS "http://git.savannah.gnu.org/cgit/libcdio.git/snapshot/libcdio-release-${VERSION}.tar.gz"
    FILENAME "libcdio-release-${VERSION}.tar.gz"
    SHA512 c67be0f6a86a67cb91e6ac473dae9612732a29f26547a38321ed9d7048bf38549ae98ff65c939221cb30b9bab42a3c05d6e0ae1b7dbaebd7cadf7d25e053ce1a
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
    0001-Fix-compatibility-with-windows.h.patch
    0002-Fix-incorrect-exports-in-internal-.sym-files.patch
    0003-driver-MSWindows-win32.c-Fix-warnings-about-missing-.patch
    0004-libcdio.sym-Correct-for-changes-in-1.0.0-release.patch
    0005-Improve-msvc-compilation.patch
    0001-Remove-doc-from-config-and-make.patch
    0003-Fix-free-while-still-in-use-in-iso9660.hpp.patch
    0004-src-cdda-player.c-always-use-s-style-format-for-prin.patch
)

if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH MSVC/libcdio.sln
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
