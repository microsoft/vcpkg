vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LTLA/powerit
    REF 705c4a6209baeaf4a246c8a61c46ecd0d3473511
    SHA512 e45172baf90fe2e76152a53feb2a3b613a355482b657e5bc71f0eca4199dff947da70b44edd87efbdc4929eb39ec4455300edaf8f95eb394f61213657c97c321
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPOWERIT_FETCH_EXTERN=OFF
        -DPOWERIT_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME ltla_powerit
    CONFIG_PATH lib/cmake/ltla_powerit
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
