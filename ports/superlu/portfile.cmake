if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiaoyeli/superlu
    REF "v${VERSION}"
    SHA512 1461b52bc18a8b0345beb70fdd46e07df497a13be840bcc061158ea1d0e61c8745806d1ad21cb2723db80f5ed762c3741f9c0ded2b2013df46da0e8bb6b77b83
    HEAD_REF master
    PATCHES
        remove-make.inc.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DXSDK_ENABLE_Fortran=OFF
        -Denable_tests=OFF
        -Denable_internal_blaslib=OFF
        -Denable_doc=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.txt")
