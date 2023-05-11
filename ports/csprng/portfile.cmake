vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Duthomhas/CSPRNG
    REF 98e75e23c469839ea62337ed11a165224ea1275e
    SHA512 d637af9a758c88762c9d1a942d6cfe98f4d95cacef80ea64650b9408f0da6fcb61295ea3f717e24de37af33add795686c8a39654001b50548f2fb0ef2779d816
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/csprng)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")
