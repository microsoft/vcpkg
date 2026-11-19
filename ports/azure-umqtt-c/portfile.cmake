vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-umqtt-c
    REF 7bd43b9792ad39036ec25b5763277ba01f04bb19
    SHA512 b77eb1c2a543d5b5e3570ebe76e45889e9e16e0a8f7ea3f3b7eaa5caa9a0bf3c35e41dc6f5161ffb73ffd1910dd6ea0e429e462a2ad8f6a2d4307b8f1e4e58ce
    HEAD_REF master
)

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
