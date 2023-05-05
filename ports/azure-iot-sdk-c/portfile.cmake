vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-iot-sdk-c
    REF 9fa25c9f996f06b57132c73b95a251a0598d786b
    SHA512 4b7ea9831bae34319710f6423a4d93a85ebe91a881d7e04d68e10dfc9828ec0bfd9cd81b55ebefa21c35e6a7f59492a2719128e7e0cab03d7afab1d6af07f43e
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
