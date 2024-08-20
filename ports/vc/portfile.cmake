vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  VcDevel/Vc
    REF 1.4.4
    SHA512 b8aa0a45637dd1e0cc23f074d023b677aab570dd4a78cff94e4c2d832afb841c1b421077ae9c848a40aa4beb50ed2e31fdf075738496856ff8fe3ea1d0acba07
    HEAD_REF 1.4
    PATCHES 
       correct_cmake_config_path.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/Vc/")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
