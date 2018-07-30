include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message("azure-c-shared-utility only supports static linkage")
    set(VCPKG_LIBRARY_LINKAGE "static")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-c-shared-utility
    REF e7aef25f8012e9e9333c72433a1d21f90f3a28b4
    SHA512 73b644bc1ea3d87fcdc0916f969fd779a20ed5ae263643dd21cc600265f84cab443f6578ff30f364ddea9e91ca4488615b78898e9c06f15cbc5d0af725ebfa00
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_AS_DYNAMIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Dskip_samples=ON
        -Duse_installed_dependencies=ON
        -Duse_default_uuid=ON
        -Dbuild_as_dynamic=${BUILD_AS_DYNAMIC}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/azure_c_shared_utility)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(COPY ${SOURCE_PATH}/configs/azure_iot_build_rules.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/azure-c-shared-utility)

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/azure-c-shared-utility RENAME copyright)

vcpkg_copy_pdbs()
