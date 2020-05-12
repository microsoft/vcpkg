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
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-c-shared-utility
        REF 48f7a556865731f0e96c47eb5e9537361f24647c
        SHA512 c20074707e8601e090ee8daac1d96fdfb4f60ac60fd9c824dad81aa4c2f22b04733c82c01c1ae92110c26871b81674e8771d9ed65081f1c0c197a362275a28f1
        HEAD_REF master
        PATCHES 
            fix-utilityFunctions-conditions.patch
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
