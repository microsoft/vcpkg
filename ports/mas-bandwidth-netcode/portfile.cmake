vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mas-bandwidth/netcode
    REF "v${VERSION}"
    SHA512 a8127d3696057409bcc7c397a3edf2f28bfb37aad34ba48b873fe6e5bc93d0d933e3e723da3e8a785b1eb1e4e4357a9eac031f0dda5665709a77bbeac1189006
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNETCODE_SYSTEM_SODIUM=ON
        -DNETCODE_BUILD_TESTS=OFF
        -DNETCODE_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME netcode CONFIG_PATH lib/cmake/netcode)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENCE")
