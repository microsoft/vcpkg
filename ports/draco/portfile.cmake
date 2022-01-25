vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/draco
    REF 1.4.3
    SHA512 f2220d5e84a4ca2d14c6bbc3dca0a2ed5c988849d3a98ce3dea910efe005e0ccdff06677d782cdb1673db9e158905aa91a9305432dc5621e8947b2d90f5996d3
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
