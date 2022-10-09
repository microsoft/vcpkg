vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/draco
    REF 1.5.3
    SHA512 8575ea78e0d8025facddbd42453b0251387f4e31eb0854135e050fc26aaf0d28ed30ccc3f93578fdc6cdb50369c2ef735291f1f5fb60238b289e0ee019446e1d
    HEAD_REF master
    PATCHES
        fix-compile-error-uwp.patch
        fix-uwperror.patch
        disable-symlinks.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/${PORT})
vcpkg_fixup_pkgconfig()

# Install tools and plugins
vcpkg_copy_tools(
    TOOL_NAMES
        draco_encoder
        draco_decoder
    AUTO_CLEAN
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
