
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/arrow-nanoarrow
    REF "2cfba631b40886f1418a463f3b7c4552c8ae0dc7"
    SHA512 9892e7e06be4c53ba884b50e0c4efbe7bccca229060e8ee534999c3a31cf74f1e3f2ec8ad778cc3b50e8834b8f11ac52b86e68c4e28365dae581917aded7ca6f
    HEAD_REF main
)

file(REMOVE_RECURSE "${SOURCE_PATH}/thirdparty")

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "dynamic" NANOARROW_INSTALL_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNANOARROW_INSTALL_SHARED=${NANOARROW_INSTALL_SHARED}
        -DNANOARROW_DEBUG_EXTRA_WARNINGS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME nanoarrow
    CONFIG_PATH lib/cmake/nanoarrow
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake" "${CURRENT_PACKAGES_DIR}/lib/cmake")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
