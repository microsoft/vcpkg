include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-iot-sdk-c
        REF d1cdf78b5160af8e08354e102a6b96395eee79e1
        SHA512 0efbfc19e5eef4831b55ded0e8d88e83194bc0f26886841ddc83405c15b7f1bae983e22dc569e22846acd78b843b9e7492883b7c502f4eed92ff80ef45a9942d
        HEAD_REF public-preview
        PATCHES improve-external-deps.patch cmake-hsm-option.patch
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-iot-sdk-c
        REF f8d260df190f90c04114ca8ff7d83dd03d4dd80d
        SHA512 111331293cfbdbdac4a6460d293ec8650bee31940829852c27afc88cc6e742e96f71c996aa275dc5ed1f13e9fe19452d7b2685dde47bb7d6c135ebee58c50d21
        HEAD_REF master
        PATCHES improve-external-deps.patch
    )
endif()

if("use_prov_client" IN_LIST FEATURES)
    message(STATUS "use prov_client")
    set(USE_PROV_CLIENT 1)
else()
    message(STATUS "NO prov_client")
    set(USE_PROV_CLIENT 0)
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
        -Duse_prov_client=${USE_PROV_CLIENT}
        -Dhsm_type_symm_key=${USE_PROV_CLIENT}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/azure_iot_sdks)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/azure-iot-sdk-c/copyright COPYONLY)

vcpkg_copy_pdbs()

