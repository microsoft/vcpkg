vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hoene/libmysofa
    REF "1f9c8df42dfd6765e390ed8840341f15e1ab997b"
    SHA512 67ce39d78981dc95cf190b1be4addceec4ecc7c2b14660da53a856be8fcff97a2f238343fccac2d042212e5a101eaf26fd12b78c86d0f6ce022bb79aa9815c67
    HEAD_REF "v${VERSION}"
    PATCHES
      use-vcpkg-zlib.patch
      skip-install-sample.patch
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
vcpkg_cmake_config_fixup(PACKAGE_NAME mysofa CONFIG_PATH lib/cmake/mysofa)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
