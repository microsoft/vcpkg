vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PaddlePaddle/FlyCV
    REF "release/v${VERSION}"
    SHA512 6f40f00f54a3d10da3f49a3c070e6cc8319c3d429d3fe4651e3ca1c55973d9610b64e05a5dec5a33dd8e6c7c293117a1d1b85e2833e07faebfd591f8fed3da14
    HEAD_REF develop
    PATCHES
        int64_and_install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TEST=OFF
        -DWITH_LIB_PNG=ON
        -DWITH_LIB_JPEG_TURBO=ON
        -DBUILD_C=ON
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
