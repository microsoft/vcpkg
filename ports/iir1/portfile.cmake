vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO berndporr/iir1
    REF "${VERSION}"
    SHA512 190464b3158fa0f2e48b67f6fee5be749da4cc0abec50cab7090f0df7785aa8e8efd1c219b6ecf7e8f7cdbe8b5e26b7250b60ec37ec69fcc87a8b92f78fd12e9
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
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/iir.pc" " -liir" " -liir_static")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/iir.pc" " -liir" " -liir_static")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
