vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO odygrd/quill
    REF v${VERSION}
    SHA512 fa945fa584d9771b44349b5e7322e41e5a6c0d623159ccb6e8fe9094382136d1dce7fcf72f55e7b37d9d0e19cd11cf6c2fbc02d407b1d18b6448bc72b6100d24
    HEAD_REF master
)

if(VCPKG_TARGET_IS_ANDROID)
    set(ADDITIONAL_OPTIONS -DQUILL_NO_THREAD_NAME_SUPPORT=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DQUILL_FMT_EXTERNAL=ON
        ${ADDITIONAL_OPTIONS}
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
if(VCPKG_TARGET_IS_ANDROID)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/quill/TweakMe.h" "// #define QUILL_NO_THREAD_NAME_SUPPORT" "#define QUILL_NO_THREAD_NAME_SUPPORT")
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
