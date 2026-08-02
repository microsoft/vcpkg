vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dougbinks/enkiTS
    REF v${VERSION}
    SHA512 6fa1f9b44c1bce36ea5b477f3f92e31c832d85183a52b3802ac983eb4fcf6f8bc5507bbdc025aa0c071a4a831601a15993aa4fe86c46576b78c4806524f0ec45
    HEAD_REF master
    PATCHES
        fix_shared_install.patch
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
vcpkg_cmake_config_fixup(PACKAGE_NAME enkiTS CONFIG_PATH lib/cmake/enkiTS)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.txt")
