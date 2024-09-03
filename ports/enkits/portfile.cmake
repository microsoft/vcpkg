vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dougbinks/enkiTS
    REF "03e6a2c0c97208ade44478d617d2002b0f95faf4"
    SHA512 2889a7b015319115f6acf74036f709b30786602f3b7205bdf401644172e2d92307f325719ccc02ad93a09557a9155e31db4d8e07f9f77e0c700d5a3365091ad3
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
