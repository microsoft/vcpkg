set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nibanks/msh3
    REF v${VERSION}
    SHA512 e6ba4e8f4ce5cd3f586d61739148bf75dfddbe70f399b2e498e7d416c8d730a5f8c2c38f0eabe687049bb7525df44f5f511515ec578bc3832989f73961cdda72
    HEAD_REF main
    PATCHES
        dependencies_fix.patch
)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
