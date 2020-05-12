vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taocpp/pegtl
    REF 2.8.1
    SHA512 7a8f6829123fbbd5a0ef1c8ef2c72bdae48576ef94056a1dff7914e4bb85caac1df02839131ea5cfb4131c8902addeca92df48fe7dd5815bdf5cb35759dace49
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
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)

# Handle collision with latest pegtl
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/pegtl-config.cmake ${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/pegtl-config-version.cmake ${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config-version.cmake)
