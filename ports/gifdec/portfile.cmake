vcpkg_download_distfile(
    FIX_CVE
    URLS https://github.com/lecram/gifdec/pull/23.patch?full_index=1
    FILENAME fix-cve.patch
    SHA512 457deb349492206c473edcc09fdc654261a2277307272c1716cc7ef42b0f75302039a7b453ddb355d7195bc5e1ac068a431f5fed5adc3161a3ee60ab03295a65
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lecram/gifdec
    REF 1dcbae19363597314f6623010cc80abad4e47f7c
    SHA512 2756004cb7dd8be5560a32c188001da503b97f1b8e3eed908787563b7e36edf8cbca3605e2e75b2ebbc69b329e16d89b3237028dfd7a772d2763bf78b1675ad2
    HEAD_REF master
    PATCHES
        "${FIX_CVE}"
)

file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
    "${CMAKE_CURRENT_LIST_DIR}/unofficial-gifdec-config.cmake.in"
    DESTINATION "${SOURCE_PATH}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-gifdec CONFIG_PATH lib/cmake/unofficial-gifdec)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/README")
