vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ambiguous_safe_shift_left_patch
    URLS https://github.com/BinomialLLC/basis_universal/commit/b738655c40efca3e0dc8c435617178fec9f7f13e.diff
    FILENAME BinomialLLC_basis_universal_safe_shift_left.diff
    SHA512 654ac6fbfc884396c1f34eee8057db796aafa811230373edc56e3d5a66ace4289a9d4f1981e1267dda7b320dc59e983b81b1bd930607f5337678246cb5d005ec
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BinomialLLC/basis_universal
    REF "v1_60"
    SHA512 9464a944b2eaad5574e5f54b5d528be29d498f53463db1e00791ed61f0c497d4f1b9f8f78dba0e99c979ce70a894f8786b5ebef4b7741bfd244c7b56b7fb04fe
    HEAD_REF master
    PATCHES
        ${ambiguous_safe_shift_left_patch}
        examples.diff
        export-cmake-config.diff
        skip-strip.diff
        devendor-zstd.diff
)
file(REMOVE_RECURSE "${SOURCE_PATH}/zstd")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_CXX_STANDARD=17
        -DBASISU_SYSTEM_ZSTD=ON
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/basisu)

vcpkg_copy_tools(TOOL_NAMES "basisu" AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(COMMENT [[
basis_universal is provided under Apache-2.0 license terms.
But it includes third-party components with different licenses.]]
    FILE_LIST
        "${SOURCE_PATH}/.reuse/dep5"
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/LICENSES/BSD-3-clause.txt"
        "${SOURCE_PATH}/LICENSES/MIT.txt"
)
