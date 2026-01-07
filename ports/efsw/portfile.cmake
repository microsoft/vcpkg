vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SpartanJ/efsw
    REF "${VERSION}"
    SHA512 465349e4333c674b1000441d48ee8e063ad09316bc55c1797a464f6c66ff7d904b7a6169d56ac2a29cc17d4be03665b2ccba8d479932cfdbba414f0d8d387488
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
