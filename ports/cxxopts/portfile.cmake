vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jarro2783/cxxopts
    REF 302302b30839505703d37fb82f536c53cf9172fa # v2.2.1
    SHA512 ba4fe586772979929e090310557b1cba66c7350593ae170e3c7bd6577cf147b20dbe3ba834f2ed6e1044a1b38d5166bfd0491ab573df68e678ff2dc792a3c442
    HEAD_REF master
    PATCHES
    fix-uwp-error.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCXXOPTS_BUILD_EXAMPLES=OFF
		-DCXXOPTS_BUILD_TESTS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/cxxopts)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cxxopts RENAME copyright)
