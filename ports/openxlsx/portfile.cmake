vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO troldal/OpenXLSX
    REF 2eb596ac69d5ef8c1a1be1de8ee481b5ce39baea
    SHA512 deeba306385569161a4c0f351a8be86222524392bffa263b90dd6f142369fc0ddfa46622536c858ef5f4eff75b70b19d642994b5e301cb4e7ead8872babe8ee4
    HEAD_REF development-aral
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DOPENXLSX_CREATE_DOCS=OFF
        -DOPENXLSX_BUILD_BENCHMARKS:BOOL=OFF
        -DOPENXLSX_BUILD_SAMPLES:BOOL=OFF
        -DOPENXLSX_BUILD_TESTS:BOOL=OFF
        -DOPENXLSX_COMPACT_MODE:BOOL=OFF
        -DOPENXLSX_CREATE_DOCS:BOOL=OFF
        -DOPENXLSX_NOWIDE_STANDALONE:BOOL=OFF
        -DOPENXLSX_LOCAL_PACKAGES_ONLY:BOOL=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/OpenXLSX")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
