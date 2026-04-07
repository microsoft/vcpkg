vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Mik1810/nxpp
    REF v1.0.1
    SHA512 107a7878989981819dcd606c0a824ec3f1e4b4416456a4c7e7520c72537e6cb25a8249418b29158cd0195a52c8fe0d5de36ab809dcabfb9312fd2d30ac39b383
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNXPP_BUILD_TESTS=OFF
        -DNXPP_BUILD_SMOKE_TESTS=OFF
        -DNXPP_BUILD_LARGE_GRAPH_COMPARE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME nxpp CONFIG_PATH lib/cmake/nxpp)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/lib"
    "${CURRENT_PACKAGES_DIR}/debug"
)

file(INSTALL
    "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)
