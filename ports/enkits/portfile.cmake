vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dougbinks/enkiTS
    REF "v${VERSION}"
    SHA512 72a05058caef8d6a33cd70500aeaf05cc61521721697969d4845279b5a79b63e7a6a3f3971c5eff2776e5575720b58252e9d251ef565c2123275a3e8540948db
    HEAD_REF master
    PATCHES
        update_install.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENKITS_BUILD_C_INTERFACE=ON
        -DENKITS_BUILD_EXAMPLES=OFF
        -DENKITS_BUILD_SHARED=${BUILD_SHARED}
        -DENKITS_INSTALL=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
# Must specify args due to case sensitivity on some filesystems
vcpkg_cmake_config_fixup(PACKAGE_NAME enkiTS CONFIG_PATH share/enkiTS)
file(RENAME "${CURRENT_PACKAGES_DIR}/share/enkiTS/enkiTS-config.cmake" "${CURRENT_PACKAGES_DIR}/share/enkiTS/enkiTSConfig.cmake")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.txt")
