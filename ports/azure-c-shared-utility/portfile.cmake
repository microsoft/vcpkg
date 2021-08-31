vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-c-shared-utility
        REF 42574842914591aadc77701aac72f18cc72319ad
        SHA512 dfe6ccede4bebdb3a39fbfea1dc55ddca57cced0d2656ee4bed1a5e5c9c434e1f2d892eb4e29bbb424cb9a02f2374a95fb9a020442bea580d39c242efad1b789
        HEAD_REF master
        PATCHES
            fix-utilityFunctions-conditions-preview.patch
            disable-error.patch
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-c-shared-utility
        REF 6efdcc1219545e301d6ba911c50471bbb30a6a1c
        SHA512 66f9ef1bd0255329489b04bc4bee8931f51798cfa7f713470d81d2068d472a616d8695e3b97399d53c6993f9a8281c82a67723900045fe866b00b72b9c485a11
        HEAD_REF master
        PATCHES
            fix-utilityFunctions-conditions.patch
            disable-error.patch
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

file(COPY ${SOURCE_PATH}/configs/azure_iot_build_rules.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

vcpkg_copy_pdbs()
