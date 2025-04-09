set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osmcode/libosmium
    REF "v${VERSION}"
    SHA512 fb87d5ae37c6d864ba1b265bda8e8a213fe9714d4e3cc47bd87ec05d07b9007494d37752ec4223bc5a2d957eac090d752d71f1944cb5200ae3d4af8ac97b9e10
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_GDAL=ON
        # for transitive dependencies via pkgconf 
        -DPKG_CONFIG_USE_CMAKE_PREFIX_PATH=1
        -DVCPKG_HOST_TRIPLET=${HOST_TRIPLET}
)
vcpkg_cmake_install()

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
