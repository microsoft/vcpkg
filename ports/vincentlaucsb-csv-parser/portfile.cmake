vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vincentlaucsb/csv-parser
    REF "${VERSION}"
    SHA512 b8d70f27be5f000880df25aa0d457e9a01053b4c851cbfe6c69a2b499fa03d75189ce73d357f28e69b8530a34b40d93e70a720f7441fa16b6dbed1cc502ba88d
    HEAD_REF master
    PATCHES
        001-fix-cmake.patch
        002-fix-include.patch
		003-disable-coverage.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_PYTHON=OFF
        -DCSV_BUILD_PROGRAMS=OFF
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
find_dependency(mio CONFIG)
find_dependency(string-view-lite CONFIG)
${cmake_config}
")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
