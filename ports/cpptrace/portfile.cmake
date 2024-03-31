vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremy-rifkin/cpptrace
    REF "v${VERSION}"
    SHA512 422f4a4f4156f8ba302a7f0e444f3a7a1d71e16804c30e679813d3518b3938b80602c3853d8d15127d2977eaa7e136e7e61841e8c31e0c39fbc160a2f318d746
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
