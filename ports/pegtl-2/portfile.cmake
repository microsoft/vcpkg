include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taocpp/pegtl
    REF 2.8.0
    SHA512 1652b0061cd4cbd0e687855ee2e61e97d020606c54329de8769c3a3f411002323900c11eaf0da28e107c17e269025f577f9205b7500c5bbb16502687be8ee77b
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPEGTL_BUILD_TESTS=OFF
        -DPEGTL_BUILD_EXAMPLES=OFF
        -DPEGTL_INSTALL_INCLUDE_DIR=include/pegtl-2
        -DPEGTL_INSTALL_DOC_DIR=share/pegtl-2
        -DPEGTL_INSTALL_CMAKE_DIR=share/pegtl-2/cmake
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/pegtl-2/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(RENAME ${CURRENT_PACKAGES_DIR}/share/pegtl-2/LICENSE ${CURRENT_PACKAGES_DIR}/share/pegtl-2/copyright)

# Handle collision with latest pegtl
file(RENAME ${CURRENT_PACKAGES_DIR}/share/pegtl-2/pegtl-config.cmake ${CURRENT_PACKAGES_DIR}/share/pegtl-2/pegtl-2-config.cmake)
