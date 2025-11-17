vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gknowles/dimcli
    REF "v${VERSION}"
    SHA512 fff7ac643b42c9c4464ac34c80369ef1e3d9d87677a3c7c660fd6a697b57348599b445794ac278d87a9a8d31c00adfded5932ecaa54e8ed918cb4665023fd8d5
    HEAD_REF master
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
