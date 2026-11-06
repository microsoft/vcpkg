vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO repology/libversion
    REF ${VERSION}
    SHA512 92126b87fc7db23317c92680c33f7b475766e835112e56083e2f7772a14fceeae73e78149975e7ff00f95695fb9aeccf7ee5d464ceb0de1c68241e01061c08b5
    HEAD_REF master
    PATCHES
        disable-test.patch
        separate-build-type.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libversion)
if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libversion.pc" "-lversion" "-llibversion")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libversion.pc" "-lversion" "-llibversion")
    endif()
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
