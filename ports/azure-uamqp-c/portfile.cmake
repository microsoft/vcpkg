include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-uamqp-c
        REF 6922680bda8581e8c8df34a764d32e62a8498943
        SHA512 1ba060efc2330967aae53b43879c7566f90ec539f28cc6e7054852235c916ad9254628415b79ff25e4191302911673ec501d97c6707e8f65a5583f687a64b2aa
        HEAD_REF master
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-uamqp-c
        REF 6922680bda8581e8c8df34a764d32e62a8498943
        SHA512 1ba060efc2330967aae53b43879c7566f90ec539f28cc6e7054852235c916ad9254628415b79ff25e4191302911673ec501d97c6707e8f65a5583f687a64b2aa
        HEAD_REF master
    )
endif()

file(COPY ${CURRENT_INSTALLED_DIR}/share/azure-c-shared-utility/azure_iot_build_rules.cmake DESTINATION ${SOURCE_PATH}/deps/azure-c-shared-utility/configs/)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Dskip_samples=ON
        -Duse_installed_dependencies=ON
        -Dbuild_as_dynamic=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/uamqp)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/azure-uamqp-c/copyright COPYONLY)

vcpkg_copy_pdbs()

