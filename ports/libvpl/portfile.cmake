vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/libvpl
    REF "c45b5d786bf7cdabbe49ff1bab78693ad78feb78"
    SHA512 36f8817ae37013058753ae56383d9301c8214472e0b83d903e68b3aefa7d258510f5ed9f72f2ec15da74467797d3ccefc4cfa52f9eaff502a967b6ef7bc67536
    HEAD_REF cmake-libvpl
    PATCHES
        vpl_config_cmake.patch
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DBUILD_EXPERIMENTAL=ON
    -DINSTALL_EXAMPLES=OFF
    -DBUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH  "lib/cmake/vpl"
PACKAGE_NAME VPL)


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

#file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
#file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
