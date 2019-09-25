include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-umqtt-c
        REF 5764c24be5db7a7c5988a5f1d63c329f68f1c8d8
        SHA512 c5a976b84a9efb0951ae60b3dc7bae9862c7eac633ced2cf252fc3133cb06f16c584f8dfd5ce74adeadc5c922742c8e8fa31813e00e80cd67c39fc1825002c64
        HEAD_REF master
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-umqtt-c
        REF 5764c24be5db7a7c5988a5f1d63c329f68f1c8d8
        SHA512 c5a976b84a9efb0951ae60b3dc7bae9862c7eac633ced2cf252fc3133cb06f16c584f8dfd5ce74adeadc5c922742c8e8fa31813e00e80cd67c39fc1825002c64
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

