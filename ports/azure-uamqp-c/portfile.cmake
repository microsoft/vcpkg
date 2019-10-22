include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-uamqp-c
        REF f9e3db3a849c851f3f1b3013ed66c0d64158c68b
        SHA512 41c2e4f56b7d85a5890dfe00db26056bca105370985e55c483df3b41d29831edff5092c36dbf39b7f65a14bbf4f4abaf3b1c2f53e9693a7214158858c31de8dc
        HEAD_REF master
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-uamqp-c
        REF f9e3db3a849c851f3f1b3013ed66c0d64158c68b
        SHA512 41c2e4f56b7d85a5890dfe00db26056bca105370985e55c483df3b41d29831edff5092c36dbf39b7f65a14bbf4f4abaf3b1c2f53e9693a7214158858c31de8dc
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

