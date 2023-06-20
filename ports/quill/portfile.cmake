vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_minimum_required(VERSION 2022-11-10)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO odygrd/quill
    REF v${VERSION}
    SHA512 92210265c0b8a38774f1b57eedd4d319034dcfe267bd4035ccf338a0b46e7393bee361d4bf379421a7e5106bae67cf64d70cad01f9c6b82655aeb859af29a8ed
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DQUILL_FMT_EXTERNAL=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/quill)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/quill/bundled")

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/pkgconfig" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(RENAME "${CURRENT_PACKAGES_DIR}/pkgconfig" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
endif()
vcpkg_fixup_pkgconfig()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/quill/TweakMe.h" "// #define QUILL_FMT_EXTERNAL" "#define QUILL_FMT_EXTERNAL")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
