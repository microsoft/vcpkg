include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-umqtt-c
        REF ea9f6112d002bdff55c94df327bc7effc8393c78
        SHA512 68FDC22EB07D32CB9CF489D878DB3BE8326225E3A067153AF7B9E29EABC8EE25162507B7E8921B71B83D42703D5A3D8E040F4A9E61A19540789432E2CECB782F
        HEAD_REF master
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-umqtt-c
        ea9f6112d002bdff55c94df327bc7effc8393c78
        68FDC22EB07D32CB9CF489D878DB3BE8326225E3A067153AF7B9E29EABC8EE25162507B7E8921B71B83D42703D5A3D8E040F4A9E61A19540789432E2CECB782F
        HEAD_REF master
    )
endif()

file(COPY ${CURRENT_INSTALLED_DIR}/share/azure-c-shared-utility/azure_iot_build_rules.cmake DESTINATION ${SOURCE_PATH}/deps/c-utility/configs/)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Dskip_samples=ON
        -Duse_installed_dependencies=ON
        -Dbuild_as_dynamic=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/umqtt)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/azure-umqtt-c/copyright COPYONLY)

vcpkg_copy_pdbs()

