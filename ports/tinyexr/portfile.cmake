vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO syoyo/tinyexr
    REF "v${VERSION}"
    SHA512 01b666903719db3ade3363dc477abbecb9d8a3b4bcb6b6a4496c76b79e67efe21cbf9cffce939cc4dda3d9656809e2365d04e17d2b70053614ae4da426ce35f0
    HEAD_REF master
    PATCHES
        fixtargets.patch
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
