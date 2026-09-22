# Header-only: there is nothing to build in debug.
set(VCPKG_BUILD_TYPE release)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tesch1/cppduals
    REF "v${VERSION}"
    SHA512 c0de79d192841791bdafab3ed0a223191d56e3dd910d4c028888e902ad5c638a7f240ed6259f66c2569bf29a0a811f45342e321e742e45d21dfb06bd7cfb231f
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
