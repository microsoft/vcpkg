include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nih-at/libzip
    REF rel-1-5-1
    SHA512 778f438f6354f030656baa5497b3154ad8fb764011d2a6925136f32e06dc0dcd1ed93fe05dbf7be619004a68cdabe5e34a83b988c1501ed67e9cfa4fa540350f
    HEAD_REF master
    PATCHES cmake_dont_build_more_than_needed.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

# Remove include directories from lib
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/libzip ${CURRENT_PACKAGES_DIR}/debug/lib/libzip)

# Remove debug include
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Copy copright information
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libzip RENAME copyright)

vcpkg_copy_pdbs()
