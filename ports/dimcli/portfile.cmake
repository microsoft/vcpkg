vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gknowles/dimcli
    REF "v${VERSION}"
    SHA512 e536e589c3e384a6a1899bfe6c6306a70d2e7614902f0beb487f00ae37181d208cb85d293e350353049dd3003c7096fcb5f187b31e4a3bb39767cc8bb85d48f3
    HEAD_REF master
    PATCHES
        include-algorithm.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" staticCrt)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DLINK_STATIC_RUNTIME:BOOL=${staticCrt}
        -DINSTALL_LIBS:BOOL=ON
        -DBUILD_PROJECT_NAME=dimcli
        -DBUILD_TESTING=OFF
        -DINSTALL_TOOLS=OFF
        -DINSTALL_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# Remove includes from ${CMAKE_INSTALL_PREFIX}/debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
