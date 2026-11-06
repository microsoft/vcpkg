vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brazier-tech/brazier
    REF "v${VERSION}"
    SHA512 ee9f07ebbeda537fbcf92a0e047bb72c5b9190b69b59e583f99b734f2fd145d1dca89013c1e2f8ff3b237345a6b1a3905524543644ddea4cf70a7b08962f22fb 
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/brazier"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_APP=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/include" 
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST 
    "${SOURCE_PATH}/LICENSE" 
    "${SOURCE_PATH}/COPYING"
)
