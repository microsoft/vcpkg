vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/veigar
    HEAD_REF master
    REF 55e025a2f9373261e1608965ef53ae425d0d6eff
    SHA512 8ea5ef4fa744bb10fb8f7cc30a761443fc5e256a336331bffec38b6cb3c66ffb0c24614dddfcfc9a81434552052d295e485d337d609d49aa5e478b726dac0e72
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" VEIGAR_USE_STATIC_CRT)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVEIGAR_USE_STATIC_CRT:BOOL=${VEIGAR_USE_STATIC_CRT}
        -DVEIGAR_BUILD_TESTS:BOOL=OFF
        -DVEIGAR_BUILD_EXAMPLES:BOOL=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/veigar)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
