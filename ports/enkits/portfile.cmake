vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dougbinks/enkiTS
    REF v${VERSION}
    SHA512 72a05058caef8d6a33cd70500aeaf05cc61521721697969d4845279b5a79b63e7a6a3f3971c5eff2776e5575720b58252e9d251ef565c2123275a3e8540948db
    HEAD_REF master
    PATCHES fix-install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENKITS_BUILD_C_INTERFACE=OFF
        -DENKITS_BUILD_EXAMPLES=OFF
        -DENKITS_INSTALL=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/unofficial-enkiTS)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.txt")
