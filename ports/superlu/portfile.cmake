if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiaoyeli/superlu
    REF "v${VERSION}"
    SHA512 8e9a7e5bcd10d7ff878f1ac9af43e5c25f9102b1895e191749e0ccf6400da1b71054ecd2fcf58e99c608f8fa26c5b8a0fa37f79dfa7fe8795c9f2505c99d8c87
    HEAD_REF master
    PATCHES
        remove-make.inc.patch
        superfluous-configure.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DXSDK_ENABLE_Fortran=OFF
        -Denable_tests=OFF
        -Denable_internal_blaslib=OFF
        -Denable_doc=OFF
        -Denable_examples=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.txt")
