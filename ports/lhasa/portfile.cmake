vcpkg_download_distfile(
    FIX_OUT_OF_TREE_BUILD_PATCH
    URLS https://github.com/fragglet/lhasa/commit/7ad404dc5d178b91405c3ac906d0ee4b3ff40c72.patch?full_index=1
    SHA512 4eb3a832d2da53f6b0b82085c89fe33ba94b4eee87c0e301c46684b7105481fe26c10f447a5adb69ee39cdd3c7e2cccd38ac4a3345fce150e21baa9bc1a42bc9
    FILENAME lhasa-7ad404dc5d178b91405c3ac906d0ee4b3ff40c72.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fragglet/lhasa
    REF "v${VERSION}"
    SHA512 14e98f48e0401efb743cd79d2af85ce20c44465c9c1e89b709b5ae34df2dd59bb090f7562fc6b434a8e9cc0fd9cc1edaaad7027a58a3a8385a45d7cd4aa1defa
    PATCHES
        "${FIX_OUT_OF_TREE_BUILD_PATCH}"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic" AND VCPKG_TARGET_IS_WINDOWS)
    # fixes error: libtool: can't build x86_64-pc-mingw32 shared library unless -no-undefined is specified
    list(APPEND OPTIONS "LDFLAGS=\$LDFLAGS -no-undefined")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${OPTIONS}
)

vcpkg_install_make()

vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_UWP)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools")
else()
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
