vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/veigar
    HEAD_REF master
    REF ${VERSION}
    SHA512 dee3a2291a8c29e40a7d093d254291b3326b24a2800d296542a3c6baec8a0bf17b6066ee8cc9b7e5431d4d7a09b8d41bdec8a0f41d6569bb2068fea867985073
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
