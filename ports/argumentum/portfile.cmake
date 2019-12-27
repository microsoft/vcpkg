include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mmahnic/cpp-argparse
    REF v0.2.1
    SHA512 26d175cf86815ed2e1f9c73e8d0eb000f3bd71eaee80ffb5d6553c21eaba6ce7617d3d95cd61fa718408f10d8c024bc171096ed0e08c4bb93bb6ac6eee2cb657
    HEAD_REF master
)

include( GNUInstallDirs )

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
    -DARGUMENTUM_BUILD_EXAMPLES=OFF
    -DARGUMENTUM_BUILD_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH ${CMAKE_INSTALL_LIBDIR}/cmake/Argumentum)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
