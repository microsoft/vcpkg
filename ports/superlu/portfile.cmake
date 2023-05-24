if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiaoyeli/superlu
    REF "v${VERSION}"
    SHA512 8feeb08404cad58724f0f6478bc785b56d8c725b549f1fdc07d3578c4e14bdbdbd8bcda1cdfd366a39417eda60765825e87cf781c68e6723a8246cb357b41439
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
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.txt")
