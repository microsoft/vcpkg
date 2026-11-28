vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Reddimus/kalshi-cpp
    REF "v${VERSION}"
    SHA512 f55569eedab711fe472e01fb6940f49a021516d525be101554c3c9a22b2966a07b22ed522cac4c662d9319f17d1c6997fc07f6be53757727313ddab2951c142e
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DKALSHI_USE_SYSTEM_GLAZE=ON
        -DKALSHI_BUILD_TESTS=OFF
        -DKALSHI_BUILD_EXAMPLES=OFF
        -DKALSHI_BUILD_BENCHMARKS=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kalshi CONFIG_PATH lib/cmake/kalshi)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
