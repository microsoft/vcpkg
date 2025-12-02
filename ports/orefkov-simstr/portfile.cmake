vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO orefkov/simstr
	SHA512 3e4629736b69ecd959e0b57bba9e893a8b15c87fd3921337f8c69a188257f2cb4498b26c57937a27e679fd445c0dac1a66de3b2c8417e7f95c93cc0e60dd3ee6
    REF "rel${VERSION}"
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS} 
        -DSIMSTR_BUILD_TESTS=OFF
        -DSIMSTR_BENCHMARKS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}") 
