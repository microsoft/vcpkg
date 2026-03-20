vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RoaringBitmap/CRoaring
    REF "v${VERSION}"
    SHA512 1559e600d9adc4701a009d9f230dcdb9a248756ecd81188637e7893803d045ecdb100fa9e10451bedec5cb1399a417867a1f4318e389d304da166d94e86ef5ba
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ROARING_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DROARING_BUILD_STATIC=${ROARING_BUILD_STATIC}
        -DENABLE_ROARING_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/roaring)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
