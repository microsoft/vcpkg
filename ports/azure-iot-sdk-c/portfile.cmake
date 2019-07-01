include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-iot-sdk-c
        REF f3f9538960d9b29033e52522dd63e985ba970504
        SHA512 f8ce98d62425da4bec1c9e99b7b662a615d90a9407e03f7ce31a56fb8848f6bda1a39156bbabf351383e490dc3438d842136220dcf08efb1560e21d9ac76a0ba
        HEAD_REF public-preview
        PATCHES improve-external-deps.patch
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-iot-sdk-c
        REF 11d5150aeb26635862cf50484af9c7e8badd52a0
        SHA512 d2cf40bca9db2c66d78f889763af3a1d06abc0e9fce19542599daec56b092e03f01f892ff420a7b107a96e0eb533579ee7eccf249b56cf6600896c77ca619fc3
        HEAD_REF master
        PATCHES improve-external-deps.patch
    )
endif()

file(COPY ${CURRENT_INSTALLED_DIR}/share/azure-c-shared-utility/azure_iot_build_rules.cmake DESTINATION ${SOURCE_PATH}/deps/azure-c-shared-utility/configs/)
file(COPY ${SOURCE_PATH}/configs/azure_iot_sdksFunctions.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmake/azure_iot_sdks/)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Dskip_samples=ON
        -Duse_installed_dependencies=ON
        -Duse_default_uuid=ON
        -Dbuild_as_dynamic=OFF
        -Duse_edge_modules=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/azure_iot_sdks)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/azure-iot-sdk-c/copyright COPYONLY)

vcpkg_copy_pdbs()

