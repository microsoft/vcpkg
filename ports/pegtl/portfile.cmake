include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taocpp/pegtl
    REF c5d158ffab4baa0e1c3f6d54c0684f05a2412f74
    SHA512 efd5d36ca14c27948005cd034e72e24855f6046141c316a1d4b7186af9753fd035dab8303dc86e2f2de1b185f5fa3f5d678672892b1fc4ab69e827492a94e897
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
