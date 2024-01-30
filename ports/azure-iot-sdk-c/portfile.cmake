vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-iot-sdk-c
    REF 97fef570416467598100b782ef27ceadad9ca796
    SHA512 faec54b97164c778ef3cd6accfbd5181381f6ab488c06900a096be5338563581552b8d8314d6ce91cb4db82c936490d3b435cdf9a3e50383e1d7bb643859a40c
    HEAD_REF master
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
