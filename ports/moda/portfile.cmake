vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dudenzz/moda
    REF "${VERSION}"
    SHA512 dabe10d5ba4e9e5bfcd1b291b16743d3639908fe961f097c89fdb99e71468442bc88d804bead86be572e2469fb28ef1fb86950d6d5201f8c844ad3ac233ea667
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