vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO syoyo/tinyexr
    REF "v${VERSION}"
    SHA512 c15ac7d21cba70c3247ea49674191097325fcba7bfaeb8163298ded2e3b67f55b1b6486fd90a80f23f950661e96c063a28a70569f40a8938cd41249c34b4bbfe
    HEAD_REF master
    PATCHES
        fixtargets.patch
        fix-uwp.patch # https://github.com/syoyo/tinyexr/pull/195
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DTINYEXR_BUILD_SAMPLE=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
