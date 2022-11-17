vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://chromium.googlesource.com/libyuv/libyuv
    REF 287158925b0e03ea4499a18b4e08478c5781541b #2021-4-15
    PATCHES
        fix_cmakelists.patch
        fix-build-type.patch
        deprecated-warning.patch
)

set(POSTFIX d)
vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_DEBUG
        -DCMAKE_DEBUG_POSTFIX=${POSTFIX}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/libyuv)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/libyuv/convert.h "#ifdef HAVE_JPEG" "#if 1")
vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/libyuv/convert_argb.h "#ifdef HAVE_JPEG" "#if 1")

configure_file(${CMAKE_CURRENT_LIST_DIR}/libyuv-config.cmake  ${CURRENT_PACKAGES_DIR}/share/${PORT} COPYONLY)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
