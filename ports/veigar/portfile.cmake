vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/veigar
    HEAD_REF master
    REF 031cb62b43621886f4412be617d797106997b67e
    SHA512 14d872f1cbf59c9645fa94892218567f9a4f386585755336a4a1cafce26b78c1e9582912b48c2a28f9c38f0e9f07f5d4b60897aa0254e28e188b65384ca64086
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
