vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pkgconf/pkgconf
    REF 458101e787a47378d2fc74c64f649fd3a5f75e55 
    SHA512 36a68c7f452752ddfa7f4740f77277bcea0c1c2c70d36d48e74ac3f77d082771253eb9b78fcd097f55cac425cecabab163123103452ddf16bff7280254c6a715
    HEAD_REF master
    PATCHES fix-static-builds.patch
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -Dtests=false
    )
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_tools(TOOL_NAMES pkgconf AUTO_CLEAN)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
