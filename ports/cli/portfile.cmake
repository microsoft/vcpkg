include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO daniele77/cli
    REF f74c6eea9616e0a62f5b3be4e1d07ad432232e90
    SHA512 9a5e25175844a7e9eacb05056c2e56e21be82efed6991d9c0e7d33e3a76f83d815455ec6e79d045ec15453354a1c50b0f91feef2766ae323931b4d4eb6caf1cf
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/cli TARGET_PATH share/cli)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cli RENAME copyright)
