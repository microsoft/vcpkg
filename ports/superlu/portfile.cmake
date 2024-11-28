if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiaoyeli/superlu
    REF "v${VERSION}"
    SHA512 d2b35ccfd4bee6f5967a1a65edc07d32a7d842aa3f623494de78cf69dc5f4819d82f675d6b2aec035fcbca0a8a3966ab76fa105e6162e8242eb6a56870e41cba
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
