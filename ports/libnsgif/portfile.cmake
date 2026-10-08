if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO netsurf-browser/libnsgif
    REF release/1.0.0
    SHA512 66f89247de14d8b2a0d53acea3114aec861a08e589a8431b18f707b4b41b5e6b2b4bcc47a7bd4028a6f10174fd037adf7707b2cad524c21c62fa88b103306d77
    HEAD_REF master
    PATCHES
        add-stddef-include.patch
)

file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
    "${CMAKE_CURRENT_LIST_DIR}/unofficial-libnsgif-config.cmake.in"
    DESTINATION "${SOURCE_PATH}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-libnsgif CONFIG_PATH lib/cmake/unofficial-libnsgif)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
