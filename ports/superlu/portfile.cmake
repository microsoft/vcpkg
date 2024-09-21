if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiaoyeli/superlu
    REF "v${VERSION}"
    SHA512 6dd2baeff9ca7ed4761845b9a30c6dca4e19ca498e10ea7360013b3aece576ca996a8bf31c4479321feda6f5266235d68ea9a2e256f0ffe91f804d4cdecd3847
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
