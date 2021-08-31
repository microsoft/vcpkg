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
        REF e4d74dce9af5e885f0f26b4f9d2f693b358b6455
        SHA512 a575f6f2a32890f52695205498223428a43d2d4fcba569217565f1837eabe14deb96eca7b3ac52efc054c4d803311e11b70917264ce706aea144737e8f967a3b
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
