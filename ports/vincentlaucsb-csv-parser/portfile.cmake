vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vincentlaucsb/csv-parser
    REF "${VERSION}"
    SHA512 409edec53974ba0358932739bf0872ed98e77f402638712e3b44ec6b8a9f1acf8129f27edc8b64129a8f311ac55e29726c58c6e03256c0f67389195195972ad9
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
