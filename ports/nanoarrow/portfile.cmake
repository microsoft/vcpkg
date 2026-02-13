
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/arrow-nanoarrow
    REF "a579fbf5d192e85b6249935e117de7d02a6dc4e9"
    SHA512 9e08268c73a1743e964c58038fbc9b175705dc1a83e3436d468dc66571f4cad8d31d55ffa0c2b9d7a9c340a93f225e34bdd13d259571cfd8809b8add448e5624
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
