vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/draco
    REF bd1e8de7dd0596c2cbe5929cbe1f5d2257cd33db #v1.5.2
    SHA512 6ae7e72a9f6f55563f8f612084d38bff1d2e10934fa84aad59538d323e59d205764ed364c753a55d80e9ffc7c17f542f6475b3f922edcb9085cbd83a942759d0
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
