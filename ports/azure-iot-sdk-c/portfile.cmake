vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-iot-sdk-c
    REF 79145b2cf2050b3a10d22003156db86f6e9c5c5e
    SHA512 771950d5472eaf49edd032ac987ea65aee8b9ef7c481c5fb8c3e1b3fb1efabcdce309e6a107949f34f78edea9704854a3791b111dce729c53fa0f041da352fb1
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
