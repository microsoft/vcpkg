vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

string(REPLACE "." "_" git_ref "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BinomialLLC/basis_universal
    REF "v${git_ref}"
    SHA512 d0ed371c2fc20d0ecff075fec60203e6992393a127c99fd52330fe519ffb27ce5786520998d87e055d47bab09b23c6afc3267db8f1aa633a8ed4f596c92627f9
    HEAD_REF master
    PATCHES
        export-cmake-config.diff
)
file(REMOVE_RECURSE "${SOURCE_PATH}/zstd")

set(SSE_FLAG OFF)
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(SSE_FLAG ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_CXX_STANDARD=17
        -DBASISU_SYSTEM_ZSTD=ON
        -DBASISU_EXAMPLES=OFF
        -DBASISU_SSE=${SSE_FLAG}
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
