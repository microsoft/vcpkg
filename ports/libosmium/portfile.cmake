set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osmcode/libosmium
    REF "v${VERSION}"
    SHA512 72e881e221dc3e62d7459b5cd84bf65de4fc0149bed66fe0534107d0d4dc30e5d474df685b44af07e6065a690dd7b31b877b5b040b8e0b4b0b971738175c34a3
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
