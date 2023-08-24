
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gazebosim/sdformat
    REF "sdformat10_${VERSION}"
    SHA512 df8ec1cc5341be57d687dfb664a9d0ff085725906e8c43d8c843b83371beaaaf0830b1447158995942c67de5700e6795fa6ccd96f0a3ee9467f33ee1cc57c38a
    HEAD_REF sdf10
    PATCHES
        cmake-config.patch
)

# Ruby is required by the sdformat build process
vcpkg_find_acquire_program(RUBY)
get_filename_component(RUBY_PATH ${RUBY} DIRECTORY)
set(_path $ENV{PATH})
vcpkg_add_to_path(${RUBY_PATH})

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTING=OFF
        -DUSE_EXTERNAL_URDF=ON
        -DUSE_EXTERNAL_TINYXML=ON
)

vcpkg_cmake_install()

# Restore original path
set(ENV{PATH} ${_path})

# Fix cmake targets and pkg-config file location
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/sdformat10")
vcpkg_fixup_pkgconfig()

# Remove debug files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/lib/cmake"
                    "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
