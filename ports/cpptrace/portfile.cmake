vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremy-rifkin/cpptrace
    REF "v${VERSION}"
    SHA512 2919880a710071b9b4efb47c126ce4eb96a466349e9c31817dd5b0f1773b82ec6d763f062484ef98d6736f964fe84a9ffccb9509cac82922abc7a776e582d97d
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DCPPTRACE_USE_EXTERNAL_LIBDWARF=ON -DCPPTRACE_VCPKG=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME "cpptrace"
    CONFIG_PATH "lib/cmake/cpptrace"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
