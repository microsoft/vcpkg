vcpkg_download_distfile(
    SYSCTL_REMOVED_PATCH
    URLS https://github.com/slembcke/Chipmunk2D/commit/9a051e6fb970c7afe09ce2d564c163b81df050a8.patch?full_index=1
    SHA512 54ec8766529d301ea35e8e0e7f7e9803101454d0f3655f7be87b6c81414a71e6fd269c14cf1d89902eebea78bb20526b0e4da4c53cf660d169ebabe46dadd059
    FILENAME 9a051e6fb970c7afe09ce2d564c163b81df050a8.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO slembcke/Chipmunk2D
    REF "Chipmunk-${VERSION}"
    SHA512 edd16544a572c8f7654c99d6420aefe2f73ce2630f3e2e969f17b4980a8ea4044b5738f4a3cefbe0edd7bb4cd039a70748773b48cd59df12a09123eca9f451e4
    HEAD_REF master
    PATCHES
        "${SYSCTL_REMOVED_PATCH}"
        export-targets.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" KEYSTONE_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" KEYSTONE_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_DEMOS=OFF
        -DBUILD_SHARED=${KEYSTONE_BUILD_SHARED}
        -DBUILD_STATIC=${KEYSTONE_BUILD_STATIC}
        -DINSTALL_STATIC=${KEYSTONE_BUILD_STATIC}
)

vcpkg_cmake_install()

if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL debug)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-chipmunk)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
