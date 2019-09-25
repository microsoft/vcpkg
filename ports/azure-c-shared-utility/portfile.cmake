include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-c-shared-utility
        REF 6061b6bfb035524f27d1245d63bbd825519423a9
        SHA512 0cf3aacc13d0752889c765272450702e348d4b17015618a25897f55a42a2b7208141dd3dca8b0bea14e7b4e4d6f8a8880ce734be61924c39a7ebc39341fa5d7f
        HEAD_REF master
        PATCHES no-double-expand-cmake.patch no-double-expand-cmake.patch
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-c-shared-utility
        REF 6061b6bfb035524f27d1245d63bbd825519423a9
        SHA512 0cf3aacc13d0752889c765272450702e348d4b17015618a25897f55a42a2b7208141dd3dca8b0bea14e7b4e4d6f8a8880ce734be61924c39a7ebc39341fa5d7f
        HEAD_REF master
        PATCHES no-double-expand-cmake.patch no-double-expand-cmake.patch
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

