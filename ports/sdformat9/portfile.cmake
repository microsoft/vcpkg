vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osrf/sdformat
    REF a978ade73e7b3509d378667dca394681e55ca068 #9.8.0
    SHA512 958c0613da7c885f81cceee726da10574188e5edafb7d3aca680e40bbdca6ff1bc7b721ee1c56c53e3973960ae715912adfa6541cf3e35d32a5dc2ef2a997505 
    HEAD_REF sdf9
    PATCHES
        fix-dependency-urdfdom.patch
        fix-quote.patch
        no-absolute.patch
        use-external-tinyxml-windows.patch
)

# Ruby is required by the sdformat build process
vcpkg_find_acquire_program(RUBY)
get_filename_component(RUBY_PATH "${RUBY}" DIRECTORY)
set(_path $ENV{PATH})
vcpkg_add_to_path("${RUBY_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTING=OFF
        -DUSE_INTERNAL_URDF=OFF
)

vcpkg_cmake_install()

# Restore original path
set(ENV{PATH} "${_path}")

# Fix cmake targets and pkg-config file location
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/sdformat9")
vcpkg_fixup_pkgconfig()

# Remove debug files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/lib/cmake"
                    "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
