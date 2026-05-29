vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taocpp/pegtl
    REF 47e878ad4fd72c91253c9d47b6f17e001ca2dfcf # 2.8.3
    SHA512 c7761e36dd28914d89a2d5e2a5ce5ea84bab50b7f7ad235b18dbeca41a675503b00b0fe152247515f81ec380f3c68cf827e667cb3b9a7e34c6d2f5dd60fb4106
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPEGTL_BUILD_TESTS=OFF
        -DPEGTL_BUILD_EXAMPLES=OFF
        -DPEGTL_INSTALL_INCLUDE_DIR=include/pegtl-2
        -DPEGTL_INSTALL_DOC_DIR=share/pegtl-2
        -DPEGTL_INSTALL_CMAKE_DIR=share/pegtl-2/cmake
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/pegtl-2/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")

# Handle collision with latest pegtl
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/pegtl-config.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/pegtl-config-version.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config-version.cmake")
