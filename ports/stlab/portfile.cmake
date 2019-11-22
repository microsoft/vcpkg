vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stlab/libraries
    REF 328ef2b423df2aadc7c932bb8d6408406714bf37 # v1.5.1
    SHA512 d9b89db678b838f9f835a5905ea81b6981cf7481c92635521967d15fc1a2e6e6f7564a7faee6242869295a3ee3179a07cad9c65cc496fb3e009277c2dbcaa6b0
    HEAD_REF develop
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/stlab)
vcpkg_copy_pdbs()

# cleanup
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/share/cmake)

# handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)