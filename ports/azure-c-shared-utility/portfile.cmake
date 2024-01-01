vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-c-shared-utility
    REF 8ee0e5d88d1771d33e36d38d392ec9d9ae13ea55
    SHA512 d57730c294340093b80108c55280ab089fa851a68c6f9df53b55823920fce25f5f1daa7ff3eeb2f8ea76bc10603aa7096931caa608c49f86e515b96477fbc81d
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
