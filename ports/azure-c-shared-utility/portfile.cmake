vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-c-shared-utility
    REF 4f1b7cd6bf48833fe4b9e23e2ff07510753faee5
    SHA512 5374585bd05ad2b55d2aa183d65b0b371d52b7f3145bcc9486e92d306d172109a8a6b13e14b56073426c3b02541044864d63fc728a9006a8dcd7ab552002be79
    HEAD_REF master
    PATCHES
        fix-install-location.patch
        fix-utilityFunctions-conditions.patch
        disable-error.patch
        improve-dependencies.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dskip_samples=ON
        -Duse_installed_dependencies=ON
        -Duse_default_uuid=ON
        -Dbuild_as_dynamic=OFF
    MAYBE_UNUSED_VARIABLES
        build_as_dynamic
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME azure_c_shared_utility CONFIG_PATH lib/cmake/azure_c_shared_utility)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(COPY "${SOURCE_PATH}/configs/azure_iot_build_rules.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)

vcpkg_copy_pdbs()
