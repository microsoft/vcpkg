include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-uhttp-c
        REF 43dce924b32818f8ab851f972cffebc204edc5c4
        SHA512 0E5E9E7DAC0C8A1A01CEA2FD9EF068F988AD3453F978957CBCB009126637FE5810001E273E7B300B4540914705A89250D96DF652C4BB2C7F5348CD8CE7240D70
        HEAD_REF master
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-uhttp-c
        43dce924b32818f8ab851f972cffebc204edc5c4
        0E5E9E7DAC0C8A1A01CEA2FD9EF068F988AD3453F978957CBCB009126637FE5810001E273E7B300B4540914705A89250D96DF652C4BB2C7F5348CD8CE7240D70
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

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/azure-uhttp-c/copyright COPYONLY)

vcpkg_copy_pdbs()

