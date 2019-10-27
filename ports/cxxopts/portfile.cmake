include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jarro2783/cxxopts
    REF v2.2.0
    SHA512 9f5182b3a86b3d47d1ce5e1e222ab596fce59d3b2dcc0ab2c3802338d5e0f3e6556f2a5ff2accb32cae7e2db41ac5a361c93bf0256f9e44c316eaa4b47c19efa
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
