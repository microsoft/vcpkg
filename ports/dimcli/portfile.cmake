vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gknowles/dimcli
    REF "v${VERSION}"
    SHA512 2d475e80e91e10244fd4c7ffeefb1f9fc84a786e2e7885d42295850e7c2dddc6572ad09a610b65e19639da9adca6ac6b6b3e6038cfed803fc2c59ae3818b4281
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
