vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-umqtt-c
    REF 9201d60bbc12a02ac5456b6105bb50919d392105
    SHA512 97d5383184c99186783738613d00e77041fe4ff3af4c14fe775e4be8b38a77a69d093ed8636a67ee85e8e09c8732b8839375aa178128f1ae58792d7c8698f829
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
