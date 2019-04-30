include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-uamqp-c
        REF 23DDABCC313FF0FC8B5DE68FC956B3EBD746CABF
        SHA512 614b36b960c20b045c91fd9fb72dd69e7fdc401ace8c9c9a492799cf19f18afd455045d9fcc5af02503ff31a08caf65b4dee92c21d8febf039c7a865bc34879a
        HEAD_REF master
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-uamqp-c
        REF 23DDABCC313FF0FC8B5DE68FC956B3EBD746CABF
        SHA512 614b36b960c20b045c91fd9fb72dd69e7fdc401ace8c9c9a492799cf19f18afd455045d9fcc5af02503ff31a08caf65b4dee92c21d8febf039c7a865bc34879a
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


