vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-c-shared-utility
    REF ceeafc67441b5b6a6d3ea32cf4bf3bcb3fa760af
    SHA512 4f6a7c803fa052f719f656bf437a904d335ed02b46ad96d35ae12521a1eb5cb08c6a18de08ba1f0cfa89ea05b23347d6e0028a7642706b8ceb55f110093b3d04
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
