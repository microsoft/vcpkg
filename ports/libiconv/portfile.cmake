if(NOT VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_ANDROID AND NOT VCPKG_TARGET_IS_IOS AND NOT VCPKG_TARGET_IS_FREEBSD AND NOT VCPKG_TARGET_IS_OPENBSD)
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/iconv")
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/iconv")
    return()
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/libiconv/libiconv-${VERSION}.tar.gz"
         "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/libiconv/libiconv-${VERSION}.tar.gz"
    FILENAME "libiconv-${VERSION}.tar.gz"
    SHA512 18a09de2d026da4f2d8b858517b0f26d853b21179cf4fa9a41070b2d140030ad9525637dc4f34fc7f27abca8acdc84c6751dfb1d426e78bf92af4040603ced86
)
vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "v${VERSION}"
    PATCHES
        0002-Config-for-MSVC.patch
        0003-Add-export.patch
        0004-ModuleFileName.patch
        clang-fortify.patch # ported from https://git.savannah.gnu.org/cgit/gnulib.git/commit/?id=522aea1093a598246346b3e1c426505c344fe19a
        0005-iOS-missing-symbol-fix.patch
)

vcpkg_list(SET OPTIONS)
if (NOT VCPKG_TARGET_IS_ANDROID)
    vcpkg_list(APPEND OPTIONS --enable-relocatable)
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    DETERMINE_BUILD_TRIPLET
    USE_WRAPPERS
    OPTIONS
        --enable-extra-encodings
        --without-libiconv-prefix
        --without-libintl-prefix
        ${OPTIONS}
)
vcpkg_install_make()

vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/iconv")

set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS enabled)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/${PORT}") # share contains unneeded doc files

# Please keep, the default usage is broken
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.LIB" "${SOURCE_PATH}/COPYING" COMMENT "
The libiconv and libcharset libraries and their header files are under LGPL,
see COPYING.LIB below.

The iconv program and the documentation are under GPL, see COPYING below.")
