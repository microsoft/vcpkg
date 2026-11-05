vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO orefkov/simstr
    SHA512 aadcf7acb57e1cc38d25e24bf3ec0d64e7c6fc7e0b9bd4d3f9d3f3c513f601e8d3d23f53c2b0169a6f149c7f3fda592b6838aef7c5b36c9ddd2fbee2bb8b35db
    REF "rel${VERSION}"
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DSIMSTR_BUILD_TESTS=OFF
        -DSIMSTR_BENCHMARKS=OFF
        -DSIMSTR_LINK_NATVIS=OFF
        -DUSE_SYSTEM_DEPS=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME simstr CONFIG_PATH lib/cmake/simstr)

set(config_file "${CURRENT_PACKAGES_DIR}/share/simstr/simstrConfig.cmake")
file(READ "${config_file}" config_contents)
file(WRITE "${config_file}" "include(CMakeFindDependencyMacro)\nfind_dependency(simdutf CONFIG)\n\n${config_contents}")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
