vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO orefkov/simstr
    SHA512 08ad3c17f693b248fcf97719ed1a65de55ab108b543508727305d00f2f9d349320822940d0f94904a3f71a7198e6fd4a42990269f38f0ee2d4d3768a66a2da6d
    REF "rel${VERSION}"
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DSIMSTR_BUILD_TESTS=OFF
        -DSIMSTR_BENCHMARKS=OFF
        -DSIMSTR_LINK_NATVIS=OFF
        -DUSE_SYSTEM_DEPS=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/simstr)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
