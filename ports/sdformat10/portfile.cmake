vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osrf/sdformat
    REF sdformat10_10.0.0
    SHA512 1caf98427d25e7c17bfacaab20382c573fac0c965b40ad0c5e0efd32ddfdaa20250d8c79ecf574989ba10b1feb884a9df3927b18ec2cd88f7c66b4d8194bc731
    HEAD_REF sdf10
    PATCHES
        fix-quote.patch
        no-absolute.patch
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
set(ENV{PATH} "${_path}")

# Fix cmake targets and pkg-config file location
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/sdformat10")
vcpkg_fixup_pkgconfig()

# Remove debug files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/lib/cmake"
                    "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
