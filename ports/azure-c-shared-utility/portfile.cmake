vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-c-shared-utility
    REF 51d6f3f7246876051f713c7abed28f909bf604e3
    SHA512 f0d88f10905739c30f43bf20861d99e7146d95ae80f1bd56979b22ef57fbbe9825bf3be9b937806e65c881ef1ba4932dc783fbabfa8ca80cc80329a409f8c20b
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
