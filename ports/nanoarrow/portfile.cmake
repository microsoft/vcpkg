
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/arrow-nanoarrow
    REF "b3f35570b92ae11f9133996cf465d94d47993e7c"
    SHA512 7af31a3e35b52e273f41c8abaebb9f63011edd55b3f5cac63d60fdd6f5bc4f97972fc72a9730894899ab35df6d62d5cdc466ba230ececedaaee2a464e60f8a6a
    HEAD_REF main
)

file(REMOVE_RECURSE "${SOURCE_PATH}/thirdparty")

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "dynamic" NANOARROW_ARROW_STATIC)
string(COMPARE NOTEQUAL ${VCPKG_LIBRARY_LINKAGE} "dynamic" NANOARROW_INSTALL_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNANOARROW_ARROW_STATIC=${NANOARROW_ARROW_STATIC}
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
