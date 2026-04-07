vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremyong/klein
    REF 92023c6a946af84e716deb1488cad22048d3e08d
    SHA512 5d12ae143f07173992a6f9aa90539c4cb6c895a7169e5c086a10f78a31f7b2c9d64faf5ce1db014bd3badd92d24ff612dd2d2dc2f7508baac59307e3dccb6ebe
    HEAD_REF master
    PATCHES
        "find_simde_first.patch"
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DKLEIN_ENABLE_PERF=OFF
        -DKLEIN_ENABLE_TESTS=OFF
        -DKLEIN_VALIDATE=OFF
        -DKLEIN_BUILD_SYM=OFF
        -DKLEIN_BUILD_C_BINDINGS=OFF
        -DKLEIN_INSTALL=ON
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

