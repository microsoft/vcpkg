vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dudenzz/moda
    REF "${VERSION}"
    SHA512 65a8260ef5d24a1e9c105eacac8f0ee68a46f085aefb326d42459229e67f8a53faf3da5fd2d8c2372f124dec2e0df77942c55e40fefde560c98723534d9913d2
    HEAD_REF cmake-sample-lib
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DEBUG_POSTFIX=d
        -DVCPKG_LIBRARY_LINKAGE=static
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME moda
    CONFIG_PATH lib/cmake/moda
)

vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/LICENSE"
)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")