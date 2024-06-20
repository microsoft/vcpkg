vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO syoyo/tinyexr
    REF "v${VERSION}"
    SHA512 583404c77009ec88d75accf006f90ee8972d2205bbae41e460d2cbb9a54d9382735a82eba0657fcc5f4e8b3b0fadd51449cec440529570e75c307eb7f0fcc8fb
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
