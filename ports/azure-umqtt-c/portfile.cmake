include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-umqtt-c
        REF 3E6FC823347824EFED712824C5F194A81FE1BB0E
        SHA512 CFDBDB4A0AC03C17C65DD6B1A6162DAF0A2A8DA697B10774563C76083C964C65725DEE64B16ABF926AD9814528C4B39452694B4898724681DAD799771E363192
        HEAD_REF master
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-umqtt-c
        REF 3E6FC823347824EFED712824C5F194A81FE1BB0E
        SHA512 CFDBDB4A0AC03C17C65DD6B1A6162DAF0A2A8DA697B10774563C76083C964C65725DEE64B16ABF926AD9814528C4B39452694B4898724681DAD799771E363192
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


