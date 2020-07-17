vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-iot-sdk-c
        REF cb2e8d390df56ffa31d08ca0a79ab58ff96160cc
        SHA512 6798b17d6768b3ccbd0eb66719b50f364cd951736eb71110e2dc9deca054a1566ff88b9e8c5e9b52536e4308cad6cd3cbebff3282c123083e3afaee5535e724b
        HEAD_REF public-preview
        PATCHES
            improve-external-deps.patch
            fix-cmake.patch
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-iot-sdk-c
        REF ff6d8659635dde7e67e658cce44e210cd7f91ecd
        SHA512 a2d0880a7818cfc80c61a02587cf0ff94ea22d50bbf9afcb125bd917ed8996d70b33afe21af0338288061f7c8212cd590759bc16ac2952d8430a1f4f08d8b269
        HEAD_REF master
        PATCHES
            improve-external-deps.patch
            fix-cmake.patch
    )
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    use-prov-client use_prov_client
)

file(COPY ${CURRENT_INSTALLED_DIR}/share/azure-c-shared-utility/azure_iot_build_rules.cmake DESTINATION ${SOURCE_PATH}/deps/azure-c-shared-utility/configs/)
file(COPY ${SOURCE_PATH}/configs/azure_iot_sdksFunctions.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmake/azure_iot_sdks/)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -Dskip_samples=ON
        -Duse_installed_dependencies=ON
        -Duse_default_uuid=ON
        -Dbuild_as_dynamic=OFF
        -Duse_edge_modules=ON
        -Dhsm_type_symm_key=${use_prov_client}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/azure_iot_sdks)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

vcpkg_copy_pdbs()