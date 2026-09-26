vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RoaringBitmap/CRoaring
    REF "v${VERSION}"
    SHA512 e7ce6c2a9257b4357bb191eb06fe1a71250112ac29a77b35af8e181435e0c19be80d815faf463b2509125c62c0ddc3686bf58201f924f3656429c82f3f0ebca6
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
