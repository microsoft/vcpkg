set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osmcode/libosmium
    REF "v${VERSION}"
    SHA512 c06396ce5417883ca84e7bef8a8443c179d1bb6d094f484ee2640a34d048d77106642229a6afa50bdb543d9f4ecdee259575f0c279f013b3a2108bf47afb8cc6
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
