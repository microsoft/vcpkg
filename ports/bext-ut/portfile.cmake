vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boost-ext/ut
    REF v1.1.9
    SHA512 81a6b80948d3a203534244f62f5f3ac57593083cc0c32484498a7d01d29455f7dcb33e2ec0587609b8dff33a81a5551796d7681d48fd93e817d6d0c31697234e
    HEAD_REF master
    PATCHES
        avoid-cpm.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBOOST_UT_BUILD_BENCHMARKS=OFF
        -DBOOST_UT_BUILD_EXAMPLES=OFF
        -DBOOST_UT_BUILD_TESTS=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME ut CONFIG_PATH lib/cmake/ut-1.1.8)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug"
                    "${CURRENT_PACKAGES_DIR}/lib"
)

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
