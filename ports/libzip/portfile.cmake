include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nih-at/libzip
    REF rel-1-4-0
    SHA512 3d8c5e64c567d2b91670ea041228d74cc8415116dfeb5c9bcf587ab817618eace668c5171122eeccf2a5f25242c2439c5f60b361f99a06274ab58aea720fe0bb
)

# Patch cmake and configuration to allow static builds
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/cmake_dont_build_more_than_needed.patch"
        "${CMAKE_CURRENT_LIST_DIR}/fix-attribute.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

# Move zipconf.h to include and remove include directories from lib
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/libzip ${CURRENT_PACKAGES_DIR}/debug/lib/libzip)

# Remove debug include
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Copy copright information
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libzip RENAME copyright)

vcpkg_copy_pdbs()
