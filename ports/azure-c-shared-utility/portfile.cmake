vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-c-shared-utility
    REF 772a4f8bc338140b4a0f404cf9c344283c5c937f
    SHA512 cd81698e58ad14b17ca87ce2ff80fd48f5bf4b6dded9d311f9ce0822b90f0f874d99210a019e00aa9a2e1c48914a4c2934f4d935638af68d2f88c5bdb26669dd
    HEAD_REF master
    PATCHES
        fix-install-location.patch
        fix-utilityFunctions-conditions.patch
        disable-error.patch
        improve-dependencies.patch
        modify-POSIX-c-version.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dskip_samples=ON
        -Duse_installed_dependencies=ON
        -Duse_default_uuid=ON
        -Dbuild_as_dynamic=OFF
    MAYBE_UNUSED_VARIABLES
        build_as_dynamic
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME azure_c_shared_utility CONFIG_PATH lib/cmake/azure_c_shared_utility)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(COPY "${SOURCE_PATH}/configs/azure_iot_build_rules.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_copy_pdbs()
