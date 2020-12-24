vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://chromium.googlesource.com/libyuv/libyuv
    REF fec9121b676eccd9acea2460aec7d6ae219701b9
    PATCHES
        fix_cmakelists.patch
        fix-build-type.patch
)

set(POSTFIX d)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DCMAKE_DEBUG_POSTFIX=${POSTFIX}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/libyuv)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/libyuv/convert.h "#ifdef HAVE_JPEG" "#if 1")
vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/libyuv/convert_argb.h "#ifdef HAVE_JPEG" "#if 1")

configure_file(${CMAKE_CURRENT_LIST_DIR}/libyuv-config.cmake  ${CURRENT_PACKAGES_DIR}/share/libyuv COPYONLY)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
