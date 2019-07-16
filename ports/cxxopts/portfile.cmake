include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jarro2783/cxxopts
    REF e6858d3429e0ba5fe6f42ce2018069ce992f3d26
    SHA512 e77b52ab506ff5f21747c3fd015a2b2bce26bdf6acb5899a3ce3acd8f890ece9687466167e1ab488a8a90544c39c775399c514cf76e55000edfc3f10c4848851
    HEAD_REF master
    PATCHES
    fix-uwp-error.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCXXOPTS_BUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/cxxopts)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cxxopts RENAME copyright)
