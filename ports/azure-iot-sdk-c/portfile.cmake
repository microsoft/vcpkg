vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-iot-sdk-c
    REF 97cb2a98767a101d7bfeb51436bd838727d7eef1
    SHA512 60171955611cb2c9925c2a3a879fd6431e053bbc152e0c5d83d9b234e4b6a8fea18cc9f9de96f5d06ae90e814916cf2333876f6728d8ef08e8b08e05d000c427
    HEAD_REF main
    PATCHES
        fix-install-location.patch
        improve-external-deps.patch
        fix-iothubclient-includes.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        use-prov-client hsm_type_symm_key
        use-prov-client use_prov_client
)

file(COPY "${CURRENT_INSTALLED_DIR}/share/azure-c-shared-utility/azure_iot_build_rules.cmake" DESTINATION "${SOURCE_PATH}/deps/azure-c-shared-utility/configs/")
file(COPY "${SOURCE_PATH}/configs/azure_iot_sdksFunctions.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/cmake/azure_iot_sdks/")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -Dskip_samples=ON
        -Duse_installed_dependencies=ON
        -Duse_default_uuid=ON
        -Dbuild_as_dynamic=OFF
        -Duse_edge_modules=ON
        -Dwarnings_as_errors=OFF
        -Dhsm_type_sastoken=OFF
    MAYBE_UNUSED_VARIABLES
        build_as_dynamic
        warnings_as_errors
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME azure_iot_sdks CONFIG_PATH "lib/cmake/azure_iot_sdks")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)

vcpkg_copy_pdbs()
