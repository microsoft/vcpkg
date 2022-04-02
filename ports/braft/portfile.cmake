vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO baidu/braft
    REF 8d0128e02a2959f9cc427d5f97ed730ee6a6b410
    SHA512 f28afbf5fe8a354872c252580e2d679f7a66944a554f0c8e9331b8a68b6a87659d59fbbc41c3ada55e09a265032290bcef567c99a7428604d08f7885f97cf6d7
    HEAD_REF master
    PATCHES
        fix-build.patch
        fix-dependency.patch
        export-target.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBRPC_WITH_GLOG=ON
        -DBUILD_TOOLS=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-braft CONFIG_PATH share/unofficial-braft)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
