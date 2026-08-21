# Header-only: there is nothing to build in debug.
set(VCPKG_BUILD_TYPE release)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tesch1/cppduals
    REF "v${VERSION}"
    SHA512 70e47ee403cd1faaf5893fdab18ea94ce90cd4e8f31d8efa3b907ceafee859f852ff33d8d92feae077c496a56fe34a505e847f86042bdc34de1c53bb417b5a50
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
