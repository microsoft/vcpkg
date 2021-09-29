vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taocpp/pegtl
    REF 3.2.1
    SHA512 6297ADEA085BB3043A60C28EB3A868A7C2D203B351F907EA3FDC4EF34C63F87A5786AC7D297531F8B8C8C3414F5DDEF658A025A7BAE2515BDC750E974975F6FF
    HEAD_REF master
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
file(RENAME "${CURRENT_PACKAGES_DIR}/share/pegtl/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
