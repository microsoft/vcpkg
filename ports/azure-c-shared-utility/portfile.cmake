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
        REF cf35f37fef2b5e9fc0322827cd601f51da2c2f42
        SHA512 eafaefd91dd39e35f4512b7da75e6bff6db3878bad0065247c90aac0119626960af6e16ce7e930ccefa220bd306d0001f8ae2e3fc19f395b52e38229256a9d6d
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
