vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO copperspice/cs_string
    REF "string-${VERSION}"
    SHA512 05ae5d4d9a919c779c4b5e21bdbb0d2dffac57571a42eff16684ddc00bd3cb67296c1b2e5e87a367db41aff85d9360ba1ad6445f2dc1cf4624f120e9bb4b70b2
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME csstring
    CONFIG_PATH cmake/CsString
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
