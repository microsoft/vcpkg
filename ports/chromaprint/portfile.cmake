vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO acoustid/chromaprint
    REF v1.5.0
    SHA512 333114949928abdf5d4b11aba1db6ec487eebe526324c68d903b3fa80a3af87a28d942af765a2f873e63a1bf222b658b6438cd10cde4446f61b26ea91f537469
    PATCHES
        fix_lrintf_detection.patch # submitted upstream as https://github.com/acoustid/chromaprint/pull/85
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)
vcpkg_install_cmake()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
