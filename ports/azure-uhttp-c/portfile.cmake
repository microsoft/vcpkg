vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-uhttp-c
        REF d84a20609a2b5a555920389451fb3c9a2ed3656c
        SHA512 4eadd7e120082cc3bcf696d6cd16bc7ee8e1082380dd7583fba7fad1bb95109f3456890495e25ae7675e656ef721fa12eff22eeb96d8a4cf359be5c96889cbd6
        HEAD_REF master
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-uhttp-c
        REF c22177c4cae57992e45e2b0db3f624c31b0f4666
        SHA512 70c011486aaf3e5af81e781d5183dcb3b6da234f9b41af9138e726bea1fd19326979a95d59bcb4314781d7ee4ef0c7fdfa9b30928a0688024d3fd93cb4168217
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
        -DCMAKE_INSTALL_INCLUDEDIR=include
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/uhttp)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

vcpkg_copy_pdbs()

