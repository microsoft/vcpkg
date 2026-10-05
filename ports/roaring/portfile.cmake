vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RoaringBitmap/CRoaring
    REF "v${VERSION}"
    SHA512 dabe0642080385e4fa6b8b5005fb045e63484480a66429b442592d4918241529eba3909ec7f3699ca259063df9ad664a0b73239a0715ddebf5b0b36d4d0e8c3a
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ROARING_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DROARING_BUILD_STATIC=${ROARING_BUILD_STATIC}
        -DENABLE_ROARING_TESTS=OFF
        -DROARING_USE_CPM=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/roaring)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST
  "${SOURCE_PATH}/LICENSE"
  "${SOURCE_PATH}/src/isadetection.c"
)
