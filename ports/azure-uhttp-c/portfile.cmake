vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-uhttp-c
        REF d84a20609a2b5a555920389451fb3c9a2ed3656c
        SHA512 4eadd7e120082cc3bcf696d6cd16bc7ee8e1082380dd7583fba7fad1bb95109f3456890495e25ae7675e656ef721fa12eff22eeb96d8a4cf359be5c96889cbd6
        HEAD_REF master
        PATCHES
            package-location-fix-preview.patch
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-uhttp-c
        REF 33485e2e43f9c8f186dfff8afda7efd905b636f1
        SHA512 ad9c8f21cee431ac39a5ffc5f1007b76c5ba1768dca6cebf8fceda33747c3accbce48ace72173cfe746316a0a136a7e770005ba98b8f99e5bb3889b5bdc2e973
        HEAD_REF master
    )
endif()

file(COPY ${CURRENT_INSTALLED_DIR}/share/azure-c-shared-utility/azure_iot_build_rules.cmake DESTINATION ${SOURCE_PATH}/deps/c-utility/configs/)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dskip_samples=ON
        -Duse_installed_dependencies=ON
        -Dbuild_as_dynamic=OFF
        -DCMAKE_INSTALL_INCLUDEDIR=include
    MAYBE_UNUSED_VARIABLES
        build_as_dynamic
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME uhttp CONFIG_PATH "lib/cmake/uhttp")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)

vcpkg_copy_pdbs()
