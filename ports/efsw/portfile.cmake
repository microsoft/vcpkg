vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SpartanJ/efsw
    REF "${VERSION}"
    SHA512 d745f1c61ca80c69aff657a25f35e07bcae548bfe15fe36a8392e467b04d67b78a271e9bdd9b744c607c8fdf558c3046ad5986a20e9b4527078f4e36c60ad5c4
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
