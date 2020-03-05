if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # Meson is not able to automatically export symbols for DLLs
endif()
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(PATCHES meson.build.patch) 
    # this patch is not 100% correct since xcb and xcb-xkb can be build dynamically in a custom triplet
    # However, VCPKG currently is limited by the possibilities of meson and they have to fix their lib dependency detection
endif()

# Get source code:
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xkbcommon/libxkbcommon
    REF e3c3420a7146f4ea6225d6fb417baa05a79c8202 # v 0.10.0
    SHA512 58f6cce838084757e052d2c2bbf989409c950ab30d373eaf5fa782ab0ead85cf2b85e006aaa194306800d004d0bc96564667dc332c9762d203e1657bdc663336
    HEAD_REF master
    PATCHES ${PATCHES}
)

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY )
get_filename_component(BISON_DIR "${BISON}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${FLEX_DIR}")
vcpkg_add_to_path(PREPEND "${BISON_DIR}")


vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -Denable-wayland=false
        -Denable-docs=false
    PKG_CONFIG_PATHS_RELEASE "${CURRENT_INSTALLED_DIR}/lib/pkgconfig"
    PKG_CONFIG_PATHS_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig"
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

