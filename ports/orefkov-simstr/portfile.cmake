vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO orefkov/simstr
	SHA512 acaee3ef575d81f117d66bb795568df005c0807c24a4528f3fc0a15f1040111241b7d191a18fd28a27181a881513374a033cebc3ef6d2c582f041512255ad319
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
