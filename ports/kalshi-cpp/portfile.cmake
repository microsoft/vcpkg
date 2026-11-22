vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Reddimus/kalshi-cpp
    REF "v${VERSION}"
    SHA512 e3df4274d3b4797c60009f30a4f0c2b9f91589a8a74160855fa47a59eccd840a9c8eab568a3f749a0bb10406709c8b31f140ab6adc5d8d176aa15d7b5144306b
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
