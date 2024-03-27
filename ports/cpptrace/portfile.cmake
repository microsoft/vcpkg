vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremy-rifkin/cpptrace
    REF "v${VERSION}"
    SHA512 ae2f9a317d70ce798c1a85d6898d073e65e21febc17c6c0127467ecb9d639f4df102cba37f2199a941a46201933fb75ae1b37cc3042d31f4c94e0279969e642a
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DCPPTRACE_USE_EXTERNAL_LIBDWARF=ON -DCPPTRACE_USE_EXTERNAL_ZSTD=ON -DCPPTRACE_VCPKG=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME "cpptrace"
    CONFIG_PATH "lib/cmake/cpptrace"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
