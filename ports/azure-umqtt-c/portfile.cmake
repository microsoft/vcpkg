include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-umqtt-c
    REF 68ee315a77382f09a8732093603c3c2f1ada08c8
    SHA512 ebee51b8eb9614bf26bedcc12e8b6419112fb344cd8b57d1c90133ba4ab7715af81fc4eca75f9b29da84c533e2e21bd1e8217a1d6ab867d49a3ab80ba9a004ff
    HEAD_REF master
)

file(COPY ${CURRENT_INSTALLED_DIR}/share/azure-c-shared-utility/azure_iot_build_rules.cmake DESTINATION ${SOURCE_PATH}/deps/c-utility/configs/)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Dskip_samples=ON
        -Duse_installed_dependencies=ON
        -Dbuild_as_dynamic=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/umqtt)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/azure-umqtt-c/copyright COPYONLY)

vcpkg_copy_pdbs()
