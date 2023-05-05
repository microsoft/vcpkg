
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gazebosim/sdformat
    REF sdformat13_${VERSION}
    SHA512 180e28631c02d92bfd17d31ec32edb234e6c56c8fad011d04198481a39bffc26355b9001c598fa63a30ce47ad8abaeaed05e3008957c5e77df3a09b0170f0e6d
    HEAD_REF sdf13
    PATCHES
        no-absolute.patch
)

# Ruby is required by the sdformat build process
vcpkg_find_acquire_program(RUBY)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTING=OFF
        -DUSE_INTERNAL_URDF=OFF
        -DUSE_EXTERNAL_TINYXML=ON
        "-DRUBY=${RUBY}"
)

vcpkg_cmake_install()

# Fix cmake targets and pkg-config file location
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/sdformat12")
vcpkg_fixup_pkgconfig()

# Remove debug files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
