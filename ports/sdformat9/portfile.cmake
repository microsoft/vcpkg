vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gazebosim/sdformat
    REF "sdformat9_${VERSION}"
    SHA512 388e1b336750c1a2b05abf3a521ea6ab809e1bbf6c4c97eaa7e11c6474a894479840910c90197bd1dbddcd4a11d983897678d31d5939afc60b647772e456bd24
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
set(ENV{PATH} ${_path})

# Fix cmake targets and pkg-config file location
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/sdformat9")
vcpkg_fixup_pkgconfig()

# Remove debug files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/lib/cmake"
                    "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
