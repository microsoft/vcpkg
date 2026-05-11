vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO troldal/OpenXLSX
    REF ed7dc3bbfaa58a01155e179a3e1afe34298082f4
    SHA512 d71bcdb77114409a0ce62b9361e6a1b8f48b945d3bfb9d41ca816dfae8c4041f488811a1f28a7c4a78dd69a8f4294b7d63872fadad08ff0969f916925b4f8117
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
