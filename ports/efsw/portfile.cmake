vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SpartanJ/efsw
    REF "${VERSION}"
    SHA512 dd5cb4d6701d4b4f562393b5f2bf55b7010e41220cb44efe3520b53f813e5b677c8ea8da2d799ecf57bed9743a72d7589431b6776a61ecc4ceef3d2218f445f6
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" EFSW_BUILD_SHARED_LIB)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" EFSW_BUILD_STATIC_LIB)

# efsw CMakeLists sets up two targets "efsw" and "efsw-static" where the former is static or shared depending on BUILD_SHARED_LIBS and the latter is always static
vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DVERBOSE=OFF
        -DBUILD_TEST_APP=OFF
        -DBUILD_SHARED_LIBS=${EFSW_BUILD_SHARED_LIB}
        -DBUILD_STATIC_LIBS=0
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/efsw)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
