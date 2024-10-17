vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taocpp/pegtl
    REF "${VERSION}"
    SHA512 aecf9396edbdd65549603484d1841cd676b197d164ee2979ee5acaf657da4fa9ebc1a59fc8550cfa440ce27794cdc59cdf86a6521e4bda084c0600cb2c92f5cf
    HEAD_REF 3.x
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPEGTL_BUILD_TESTS=OFF
        -DPEGTL_BUILD_EXAMPLES=OFF
        -DPEGTL_INSTALL_DOC_DIR=share/pegtl
        -DPEGTL_INSTALL_CMAKE_DIR=share/pegtl/cmake
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/pegtl/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
