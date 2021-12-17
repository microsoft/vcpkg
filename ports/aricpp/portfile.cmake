vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO daniele77/aricpp
    REF v1.1.1
    SHA512 b1e02b9ba9afc1f3315e238cd61b98a8d28eee08ddbaccaf171aa77d27ecec2b3abfaa5aae6905f9c2a1c83b0095a135f2186c977a0ae0cfafb48e3690814183 
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/aricpp)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_fixup_pkgconfig()
