vcpkg_fail_port_install(ON_TARGET "linux" "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osrf/sdformat
    REF sdformat9_9.2.0
    SHA512 6fc7d0ce46d9a7d1cae4fd905ebe6a07bb4ba98faa267be92a32b3409d6d82a99d5082485008a15484f7b5be2c347b5b24bc472fb1a4be5eb8b678b105cae6af
    HEAD_REF sdf9
    # Backport of https://github.com/osrf/sdformat/pull/269
    PATCHES respect-build-testing.patch
)

# Ruby is required by the sdformat build process
vcpkg_find_acquire_program(RUBY)
get_filename_component(RUBY_PATH ${RUBY} DIRECTORY)
set(_path $ENV{PATH})
vcpkg_add_to_path(${RUBY_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DBUILD_TESTING=OFF
        -DUSE_EXTERNAL_URDF=ON
        -DUSE_EXTERNAL_TINYXML=ON
)

vcpkg_install_cmake()

# Restore original path
set(ENV{PATH} ${_path})

# Fix cmake targets and pkg-config file location
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/sdformat9")
vcpkg_fixup_pkgconfig()

# Remove debug files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/debug/lib/cmake
                    ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
