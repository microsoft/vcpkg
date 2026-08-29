# Header-only: there is nothing to build in debug.
set(VCPKG_BUILD_TYPE release)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tesch1/cppduals
    REF "v${VERSION}"
    SHA512 ea9a7a665642554af6ecdd938f08195412c7c34293b9b01b9a2ca3bbd04bb6f79717f338f52d8545548b3d879b8b8281e43f1724792074bb8433e320d24caf62
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
