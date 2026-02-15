vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vincentlaucsb/csv-parser
    REF "${VERSION}"
    SHA512 d6314bbff657904a04bc5e2ccbb1cd07baf0c032f4d6f10cb56f24edda073cb75cd79c1993e690f38407bca73811136dc5837bed70d75d681cfa8200f799f4de
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
