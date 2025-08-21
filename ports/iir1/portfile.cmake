vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO berndporr/iir1
    REF "${VERSION}"
    SHA512 f50b925394f79662ae021c02e60667273a5d4615f2ef9f88d256c3c6dbb0f7d851207b65e2da56b69a97e576b3bb611653fde421df4ae0a952615d29be2f33a6
    HEAD_REF master
    PATCHES
        fix-shared-lib.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DIIR1_BUILD_TESTING=OFF
        -DIIR1_BUILD_DEMO=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME iir CONFIG_PATH lib/cmake/iir)
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/iir.pc" " -liir" "-liir_static")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/iir.pc" " -liir" " -liir_static")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
