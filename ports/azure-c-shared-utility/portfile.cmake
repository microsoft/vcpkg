include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-c-shared-utility
        REF 244CFA4C2EED5BDB979AC7B76AF02EAFECE9DE29
        SHA512 b450a27bae0ee3d1f9db237551c9d91ffce1f625499f5a45117e6b7c4b27efbc58a84b165714f09993b46f433b891937ef82d351be106ca0aa9ae7d59cb688c4
        HEAD_REF master
        PATCHES no-double-expand-cmake.patch
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-c-shared-utility
        REF 244CFA4C2EED5BDB979AC7B76AF02EAFECE9DE29
        SHA512 b450a27bae0ee3d1f9db237551c9d91ffce1f625499f5a45117e6b7c4b27efbc58a84b165714f09993b46f433b891937ef82d351be106ca0aa9ae7d59cb688c4
        HEAD_REF master
        PATCHES no-double-expand-cmake.patch
    )
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Dskip_samples=ON
        -Duse_installed_dependencies=ON
        -Duse_default_uuid=ON
        -Dbuild_as_dynamic=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/azure_c_shared_utility)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(COPY ${SOURCE_PATH}/configs/azure_iot_build_rules.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/azure-c-shared-utility)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/azure-c-shared-utility/copyright COPYONLY)

vcpkg_copy_pdbs()


