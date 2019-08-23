include(vcpkg_common_functions)

vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO blaze-lib/blaze
    REF cac64f2b35002f74a8ad2410ce6fb562b2cd2371
    SHA512 89381d77e518cdea40b0aa5013b8c74cbd737a2ce8d2d6869df1789a8154d2170c692ce04cae907704808fcff4a52fe0860d3fa2ee898780ce650a294b10894f
    HEAD_REF master
    PATCHES
        avoid-src-dir-generation.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBLAZE_SMP_THREADS=C++11
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/blaze/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/blaze)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/blaze/LICENSE ${CURRENT_PACKAGES_DIR}/share/blaze/copyright)
