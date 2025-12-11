vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dudenzz/moda
    REF "${VERSION}"
    SHA512 ebc87e613646304a37e21a5b05974ac01ee6a534049f1f27a6ea7404cd415f674eec125cad4beee907e9b9959c61da0a3ac7a78b91cdf4d4699f1fc232a576b9
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