vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO F2I-Consulting/fesapi
    REF "v${VERSION}"
    SHA512 1ccbcef17f484f1aebbfff0347fd4aaf51d86d9389645cf2059cc6d47d69863c9bde368df438ac7d9146c6dd111d1da6bac1910146977629ff0a7cddb5848a08
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Wno-dev
        -Wno-deprecated
        -DWITH_EXAMPLE:BOOL=OFF
        -DWITH_TEST:BOOL=OFF
        -DWITH_DOTNET_WRAPPING:BOOL=OFF
        -DWITH_JAVA_WRAPPING:BOOL=OFF
        -DWITH_PYTHON_WRAPPING:BOOL=OFF
        -DWITH_RESQML2_2:BOOL=ON
        "-DHDF5_PREFER_PARALLEL=${HDF5_WITH_PARALLEL}"
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(
    CONFIG_PATH "lib/cmake/FesapiCpp"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
