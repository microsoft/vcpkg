vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taocpp/pegtl
    REF 3.2.2
    SHA512 7ad055e38b362d6b90a49d5deb400948febfbcc30898e05548424bc758f38ffb3f69ca0db41e4480697f8916c90bdb3e48927a4db0caa7a20c8012b1a6d1fe08
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
