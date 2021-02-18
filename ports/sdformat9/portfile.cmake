vcpkg_fail_port_install(ON_TARGET "linux" "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osrf/sdformat
    REF sdformat9_9.4.0
    SHA512 b7ed458a5a9ba5b5dcf457d3e0c9de0bca3d514a6870aa977a00a84f8a3b8d1bd21f3b437c0651af7f0cc9b9c6c8b905c968525194605b334ab62280b9d55b0e 
    HEAD_REF sdf9
    PATCHES
        fix-dependency-urdfdom.patch
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
