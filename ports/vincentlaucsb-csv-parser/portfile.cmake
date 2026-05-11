vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vincentlaucsb/csv-parser
    REF "${VERSION}"
    SHA512 a4d8ddce2a99c1a459ca3d63280181295f7be999e46301de3718131db3d3dd8dc81b89a25b0687ee210d1887829e971b8dcc3d96f320161a23bd5d6fbb2c3d0f
    HEAD_REF master
    PATCHES
        001-fix-cmake.patch
        002-fix-include.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/include/external")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_PYTHON=OFF
        -DCSV_BUILD_PROGRAMS=OFF
        -DENABLE_CODE_COVERAGE=OFF
        -DCSV_CXX_STANDARD=17
    MAYBE_UNUSED_VARIABLES
        BUILD_PYTHON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-vincentlaucsb-csv-parser)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(READ "${CURRENT_PACKAGES_DIR}/share/unofficial-vincentlaucsb-csv-parser/unofficial-vincentlaucsb-csv-parser-config.cmake" cmake_config)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/unofficial-vincentlaucsb-csv-parser/unofficial-vincentlaucsb-csv-parser-config.cmake"
"include(CMakeFindDependencyMacro)
find_dependency(Threads)
find_dependency(mio)
${cmake_config}
")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
