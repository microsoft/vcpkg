include(vcpkg_common_functions)

set( VCPKG_LIBRARY_LINKAGE static )

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mmahnic/cpp-argparse
    REF v0.2.0
    SHA512 f2eb8c9aee8ce515d2ec3e973ceedd916458713055e1dd16e8a780cda7545b617ad0c64cd18c6356ad7584108aba3165a379ef0d3edfd89691a6343b4918e143
    HEAD_REF master
)

# vcpkg_from_git(
#     OUT_SOURCE_PATH SOURCE_PATH
#     URL https://localhost/mmahnic/argumentum.git
#     REF 310a4dd0c936f36599f76d64d4b4ec68818d8bfe
#     HEAD_REF name_change
# )

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
