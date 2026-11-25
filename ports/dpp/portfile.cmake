vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brainboxdotcc/DPP
    REF "v${VERSION}"
    SHA512 db5c840aa6ce91f6106e3ffa7ffc27df1f293f845e9613f2554489b28c192e917aa3f311211eeae59ca6e51df968bb14ad1d98402c64902262ebb84c3d40de3a
    PATCHES
        use-external-json.patch
)

file(REMOVE_RECURSE
    "${SOURCE_PATH}/include/dpp/nlohmann"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DAVX_TYPE=AVX0
        -DDPP_USE_EXTERNAL_JSON=ON
        -DDPP_BUILD_TEST=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(NO_PREFIX_CORRECTION)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share/dpp"
)

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/mlspp/LICENSE" # BSD-2-Clause
        "${SOURCE_PATH}/src/dpp/dave/clock.h" # MIT
        "${SOURCE_PATH}/src/dpp/dave/leb128.h" # BSD-3-Clause
)
