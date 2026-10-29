vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Reddimus/kalshi-cpp
    REF "v${VERSION}"
    SHA512 1646af146ad50e1214730cb88321292caee1322a775185c99ffd1b2d42e34b6088bafd898debef2bdb9509ed22711dd070d89d7f06636f2ca9b22234d75b3307
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
