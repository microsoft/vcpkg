vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PJK/libcbor
    REF "v${VERSION}"
    SHA512 c14aaa55c0c82e09b9eb2cc6847951d1bac8a081a247776c507d5450367da5717b1056bad09fb0f0178311de8754e8f89c060e0fc0f400fafdc42de441421e66
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWITH_TESTS=OFF
        -DWITH_EXAMPLES=OFF
        -DVCPKG_VERBOSE=ON
        -DSANITIZE=OFF
        -DCBOR_CUSTOM_ALLOC=ON
)

vcpkg_cmake_build()
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

# Add Cmake Packagefile
file(COPY "${CMAKE_CURRENT_LIST_DIR}/LibCborConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
