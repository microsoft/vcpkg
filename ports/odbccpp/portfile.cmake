vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SAP/odbc-cpp-wrapper
    REF "v${VERSION}"
    SHA512 8e79536bc24bd4f59ddc9554824df255fabb7ca651839ff2c90f8a352f61da99beb1df5042c2785d86a3294bcf8c0a93064ed89a62400063755cb5a7df47ca58
    HEAD_REF master
    PATCHES
        use-vcpkg-unixodbc.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGTEST_FOUND=OFF
        -DDOXYGEN_FOUND=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")