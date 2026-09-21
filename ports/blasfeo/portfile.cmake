vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO giaf/blasfeo
    REF 60493284741b3e4e5b0bf25155221d4b5f0b2232
    SHA512 d70e094fd8884f8523ff82fa81e7a578f16be4960233467f19db053e1d7d21a1b84ef629fb9cbb86e16053f87c283c053c3ed1385c8cbd85c05b816ce1744253
    HEAD_REF master
    PATCHES
        alloc-guard.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    # configure_file() writes include/blasfeo_target.h into the source tree
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        # Portable C kernels: the only target buildable everywhere (and the only one MSVC accepts)
        -DTARGET=GENERIC
        -DBUILD_SHARED_LIBS=${BUILD_SHARED}
        -DBLASFEO_EXAMPLES=OFF
        -DBLASFEO_TESTING=OFF
        -DBLASFEO_BENCHMARKS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/blasfeo)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
