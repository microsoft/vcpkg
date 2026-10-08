# Header-only: there is nothing to build in debug.
set(VCPKG_BUILD_TYPE release)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tesch1/cppduals
    REF "v${VERSION}"
    SHA512 2202382b1f85f6f5f5918d0b747023b538fc7e14ba9074426d5d59e45f2867f3abbb7a266def1896be2ab518b241dedd445ddf774bf528ece80060ec58a9e6fe
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCPPDUALS_TESTING=OFF
        -DCPPDUALS_BENCHMARK=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME cppduals CONFIG_PATH lib/cmake/cppduals)

# No libraries to ship, only headers and the CMake package files.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
