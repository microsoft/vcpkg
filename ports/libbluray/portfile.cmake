vcpkg_from_gitlab(
    GITLAB_URL https://code.videolan.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO videolan/libbluray
    REF ${VERSION}
    SHA512 30ccbbfcd168c8e2ad55ed7043a3732f45069aa582f902b6e3dca753946f0fc565f7624ac00eb53e48c458b7b88b3f8e461fa2dcc006a147598fd8cc3c604be0
    PATCHES
        msvc.diff
)

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

if("freetype" IN_LIST FEATURES)
    list(APPEND options --with-freetype)
else()
    list(APPEND options --without-freetype)
endif()

if("fontconfig" IN_LIST FEATURES)
    list(APPEND options --with-fontconfig)
else()
    list(APPEND options --without-fontconfig)
endif()

if("libxml2" IN_LIST FEATURES)
    list(APPEND options --with-libxml2)
else()
    list(APPEND options --without-libxml2)
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        --disable-examples
        --disable-bdjava-jar
        --disable-doxygen-doc
        ${options}
)

vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
