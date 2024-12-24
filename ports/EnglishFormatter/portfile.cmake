vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yourusername/EnglishFormatter
    REF v1.0.0
    SHA512  254C0B0C980995EAD58D13887E238B80CE0245E61008A32B97EA4B701F288135862
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/EnglishFormatter)
