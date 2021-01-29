# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Neargye/nameof
    REF v0.9.4
    SHA512 658abf7da2bbc831648aca017815e6368163335840d59f4538ecc0d8438dc3843ad6efc9c2ca8ec1f6ad2208349eee880106fc60cda44bd7b19c73a1f23d067f
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DNAMEOF_OPT_BUILD_EXAMPLES=OFF
        -DNAMEOF_OPT_BUILD_TESTS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/nameof TARGET_PATH share/nameof)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
