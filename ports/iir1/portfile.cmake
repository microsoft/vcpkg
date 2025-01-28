vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO berndporr/iir1
    REF "${VERSION}"
    SHA512 2b0658a621cdfb57796cf2fea5411975b442af4af267bce2f613ae53f43572f208fdea59d7ea0178e9984e311c406f289166789aa423505ac8ed2b889ddc9f64
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
