if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MediaArea/ZenLib
    REF v0.4.39
    SHA512 f36c07b7780d9ac6d65198e52a370f0c7bf931e00aa9ae17c198851d6047e55fffa4642f070ccfe348a041604b63d8710b84f2a1de96135ee9e5be1405c9bcd7
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/Project/CMake"
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME zenlib CONFIG_PATH share/zenlib)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/License.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libzen" RENAME copyright)
