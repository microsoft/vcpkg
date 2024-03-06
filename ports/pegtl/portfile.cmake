vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taocpp/pegtl
    REF cf639f7f4ee125f68e1ccfba8d99ebc0de57b9fe
    SHA512 174148310e9d2fd37c67c3e5f4fd84c66847647732ebed29878e967b44aa87bcf91c304b2193ebf11b8586e458cd13f12d6ceec2fbf33a1aaeb552a100a6307f
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
