vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Reddimus/kalshi-cpp
    REF "v${VERSION}"
    SHA512 ce86b085050a42bd27fd62d7278010a40668f485fc15efbbabc816d60aeb46141db9ea8d9c42d1cc7029525d5ee17e3ed0ec95c4ff3f9979507cb362dc2332e7
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
