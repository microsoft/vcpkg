include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-iot-sdk-c
        REF A8FDA7D444D176AF5CBE197501D9E1AF58D0A479
        SHA512 6D803655FD60B38FE5A133E177D569DA7EDEBEFB2FEFAB7988B1A94B4C2730E2C4F00C60C0A883CE7ADB358C6EFD7D974C39EDBBAB332BA7D638FEE868260C14
        HEAD_REF public-preview
        PATCHES improve-external-deps.patch
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-iot-sdk-c
        REF BFD6B6FAAF42B4405D6B652FC70CC2B80449E28B
        SHA512 4D715D9E7E3805D3583EC040B62170A819E081AFEEAE8CEB5089A1DCF3B824928E343BC7DB0BBECAE6113891F7545729BB39412700F1ABCD5B4A2493246F6C3F
        HEAD_REF master
        PATCHES improve-external-deps.patch
    )
endif()

file(COPY ${CURRENT_INSTALLED_DIR}/share/azure-c-shared-utility/azure_iot_build_rules.cmake DESTINATION ${SOURCE_PATH}/deps/azure-c-shared-utility/configs/)

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


