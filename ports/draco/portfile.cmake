vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/draco
    REF 1.5.2
    SHA512 759ccd71e7b032d32e97ac6a232a5436d52acb1bdda49808b3e90e69a9636e56724e4e22e3abf6768a2ef3fc2dcac8105bb32b396f8456070da1d2cce875fb87
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

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake)
vcpkg_fixup_pkgconfig()

# Install tools and plugins
vcpkg_copy_tools(
    TOOL_NAMES
        draco_encoder
        draco_decoder
    AUTO_CLEAN
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
