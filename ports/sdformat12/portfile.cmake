
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gazebosim/sdformat
    REF sdformat12_12.0.0
    SHA512 234e1378bf82108a5d8e8e3e199d554911531ffd36e9610720b0e2ccbd044c185aca1937dcd171c979fd9332dc4f4685c6632f46818a9dec8ff50444b99ba0de
    HEAD_REF sdf12
    PATCHES
        no-absolute.patch
)

# Ruby is required by the sdformat build process
vcpkg_find_acquire_program(RUBY)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTING=OFF
        -DUSE_EXTERNAL_URDF=ON
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
