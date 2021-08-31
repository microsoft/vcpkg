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
            remove-werror.patch
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-iot-sdk-c
        REF 82cd716ba6d966ed95f7b6117550ab8c0d6c76be
        SHA512 0b553a1fd06ba1eb11eff60244bb376e551a299a8968618bd1fc669ba9fa5377a9927dc6bcf262e4e00f6e31710ea8ec55f154ddb7c4c2ec7b7a20e2929270dc
        HEAD_REF master
        PATCHES
            improve-external-deps.patch
            fix-cmake.patch
            remove-werror.patch
    )
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        use-prov-client hsm_type_symm_key
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
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/azure_iot_sdks)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

vcpkg_copy_pdbs()
