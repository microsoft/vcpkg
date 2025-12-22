vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO orefkov/simstr
	SHA512 7d60b3f8444f0de246c1930833edf9999ffa5c39ae3bb175f1dce67923a71cf434fbd90e1a962b1a8c8d49567cd2364d6b6e8b33076a0d7cb6818c01dd42bf00
    REF "rel${VERSION}"
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS} 
        -DSIMSTR_BUILD_TESTS=OFF
        -DSIMSTR_BENCHMARKS=OFF
		-DSIMSTR_LINK_NATVIS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/simstr)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}") 
