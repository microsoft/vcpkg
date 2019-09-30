include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taocpp/pegtl
    REF cfd5e55d73a2a64942b42226e0e919dc36ecdce5
    SHA512 ee5465e9c5ffdb24e5ecd214952d1fa498e34d1e206ae2a3569a15e003ba8c3325b74a796cac1c206bdede136aaaad01c976ed18fe40dc31c7531f5049931a83
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPEGTL_BUILD_TESTS=OFF
        -DPEGTL_BUILD_EXAMPLES=OFF
        -DPEGTL_INSTALL_DOC_DIR=share/pegtl
        -DPEGTL_INSTALL_CMAKE_DIR=share/pegtl/cmake
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/pegtl/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(RENAME ${CURRENT_PACKAGES_DIR}/share/pegtl/LICENSE ${CURRENT_PACKAGES_DIR}/share/pegtl/copyright)
