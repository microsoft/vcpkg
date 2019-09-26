include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-c-shared-utility
        REF 1f3fd807c8c47b6607d349469301afb64643aa89
        SHA512 312ef2668ad62cb676c51474ba08307bacf9843d661233f7a6145e565ae58dcecb7bfa2e8a157efef1b54e8c07621bf2ec47b4d76ea180d77767b1ad44b951c2
        HEAD_REF master
        PATCHES no-double-expand-cmake.patch
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-c-shared-utility
        REF 1f3fd807c8c47b6607d349469301afb64643aa89
        SHA512 312ef2668ad62cb676c51474ba08307bacf9843d661233f7a6145e565ae58dcecb7bfa2e8a157efef1b54e8c07621bf2ec47b4d76ea180d77767b1ad44b951c2
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

