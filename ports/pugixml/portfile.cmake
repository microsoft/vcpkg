vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeux/pugixml
    REF 08b3433180727ea2f78fe02e860a08471db1e03c #v1.11.4
    SHA512 998f54203fbf81ad08d21964acb5b9ad00bf5b9eff6a0e88b93d97d0c6eda4bb75e12bb5f6a937c81b4582a415662f9ede77abe2ab3c48188d1a3768053b9c08
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DUSE_POSTFIX=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/pugixml)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/readme.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
