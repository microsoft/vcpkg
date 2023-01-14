vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-umqtt-c
        REF 7557db6de094b67818d3c410dc95a3cf07cd86a6
        SHA512 f2577379f711e2576fdd6dfecbc4d8a0b26c7670a77bc468238e8dd5fa43f208db85eddd06dd570fde4219ba19304338c712f671c059c6cc10abb4892d58ae40
        HEAD_REF master
        PATCHES
            package-location-fix-preview.patch
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-umqtt-c
        REF 566127ad605172735b9ac5cc6797261f3dd6c45c
        SHA512 19e997e1dd7ecfbf5e8f11f44daa89cee7aa793f95aaed4bdaf792f5443173e0ca434d69f68a6633ee7cdc504d03a42f4b4e8aeec549c7ffdbd5e03db8cce6b5
        HEAD_REF master
    )
endif()

file(COPY "${CURRENT_INSTALLED_DIR}/share/azure-c-shared-utility/azure_iot_build_rules.cmake" DESTINATION "${SOURCE_PATH}/deps/c-utility/configs/")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dskip_samples=ON
        -Duse_installed_dependencies=ON
        -Dbuild_as_dynamic=OFF
    MAYBE_UNUSED_VARIABLES
        build_as_dynamic
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME umqtt CONFIG_PATH "lib/cmake/umqtt")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)

vcpkg_copy_pdbs()
