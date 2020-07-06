
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mobius3/font-chef
    REF v1.0.1
    SHA512 4421a1f5f05de9fe728bc242c75212246a65fd266fa6e3a67ba34f8182fcab32284dc28979a17fc47b033e7902a4d5fd93fcf881f15df4d7477e09788df23bb2 
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()


vcpkg_fixup_cmake_targets(CONFIG_PATH "/lib/cmake/font-chef/")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake/font-chef)

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/font-chef RENAME copyright)
