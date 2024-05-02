vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO honeybunch/libmysofa
    REF "6d475b650a79c1b6bb926f07751d2ddc7ba19504"
    SHA512 a26d3f01c7a36975022ded0010a8f4b947ef45a19221ed91fcd4e89595acc2b5a40091cd7b404c8a55fb5c4bd7703886bd7750191e5f6b19d209c794dc2ec60b
    HEAD_REF "v${VERSION}"
    PATCHES
      fix-exports.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_SHARED_LIBS=${BUILD_SHARED}
        -DBUILD_STATIC_LIBS=${BUILD_STATIC}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME libmysofa CONFIG_PATH lib/cmake/libmysofa)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
