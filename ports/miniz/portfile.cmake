vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO richgel999/miniz
    REF 2.2.0
    SHA512 0bb2b0ac627715b90ff9fd69ca8958a0bea387bd7ddf5c200daba953b98ef788092e3009842f4f123234e85570159250c8897a30c1c1f2d4dea9bca9837f6111
    HEAD_REF master
    PATCHES
        fix-pkgconfig-location.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DINSTALL_PROJECT=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs(BUILD_PATHS "${CURRENT_PACKAGES_DIR}/bin/*.dll")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/miniz)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
