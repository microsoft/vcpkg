if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lecram/gifdec
    REF 1dcbae19363597314f6623010cc80abad4e47f7c
    SHA512 2756004cb7dd8be5560a32c188001da503b97f1b8e3eed908787563b7e36edf8cbca3605e2e75b2ebbc69b329e16d89b3237028dfd7a772d2763bf78b1675ad2
    HEAD_REF master
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
