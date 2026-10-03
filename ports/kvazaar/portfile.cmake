vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ultravideo/kvazaar
    REF "v${VERSION}"
    SHA512 fdb26de258e923c0cfa6741421689fc1d77c9b37040776e25d28d148d5254968e72d9716c26df45c3150afcac33a8fd61625488aa951183a1a1a347cc6f53fa7
    HEAD_REF master
    PATCHES
        gate_getopt.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIBS)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tool   BUILD_KVAZAAR_BINARY
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TESTS=OFF
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
if(BUILD_KVAZAAR_BINARY)
    vcpkg_copy_tools(TOOL_NAMES kvazaar AUTO_CLEAN)
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/kvazaar.h"
        "#define KVAZAAR_H_"
        "#define KVAZAAR_H_\n#define KVZ_STATIC_LIB"
    )

    if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/kvazaar.pc" "-lkvazaar" "-llibkvazaar")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/kvazaar.pc" "-lkvazaar" "-llibkvazaar")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
list(APPEND COPYRIGHT
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/LICENSE.EXT.greatest"
        "${SOURCE_PATH}/src/threadwrapper/LICENSE"
        "${SOURCE_PATH}/src/extras/libmd5.h"
        "${SOURCE_PATH}/src/extras/libmd5.c")
if(BUILD_KVAZAAR_BINARY)
    list(APPEND COPYRIGHT "${SOURCE_PATH}/src/extras/getopt.h")
endif()
vcpkg_install_copyright(
    FILE_LIST
        ${COPYRIGHT}
)
