vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremy-rifkin/cpptrace
    REF "v${VERSION}"
    SHA512 76f82aa11fb9e786cb246d9620c30de6f4c24353136e2597767f567f9d6fc83652120250fe8ca36aff6e3d95044a3edbc11a2607f72c46d3c2bfe168c3b9bcbb
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
