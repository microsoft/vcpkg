set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osmcode/libosmium
    REF "v${VERSION}"
    SHA512 cb53b631a1e58b8ae13cedf58d4b1552b679e67862c1c3d2df1adec31bec60e8ebc941f22f5c318f1224bfb274bdd534926148506a0c3f0f10041e4adfa84bb9
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
