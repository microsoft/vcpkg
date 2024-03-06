vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PJK/libcbor
    REF "v${VERSION}"
    SHA512 23c6177443778d4b4833ec7ed0d0e639a0d4863372e3a38d772fdce2673eae6d5cb2a31a2a021d1a699082ea53494977c907fd0e94149b97cb23a4b6d039228a
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
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
