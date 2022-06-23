vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PJK/libcbor
    REF v0.9.0
    SHA512 710239f69d770212a82e933e59df1aba0fb3ec516ef6666a366f30a950565a52981b0d46ca7e0eea739f5785d79cc21fc19acd857a4a0b135f4f6aa3ef5fd3b0
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

# Add Cmake Packagefile
file(COPY "${CMAKE_CURRENT_LIST_DIR}/LibCborConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
