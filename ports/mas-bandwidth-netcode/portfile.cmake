vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mas-bandwidth/netcode
    REF "v${VERSION}"
    SHA512 871a6bd415807defaa58e8837601a6d8b760bbec1a4ad3e6a70b83ddda52c269826dc208a213b26161de24a93ba86e0f588b5dec623dccf4b1b684f70edd901b
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENCE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
