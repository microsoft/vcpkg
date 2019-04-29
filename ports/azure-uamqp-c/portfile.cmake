include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-uamqp-c
        REF 23DDABCC313FF0FC8B5DE68FC956B3EBD746CABF
        SHA512 614B36B960C20B045C91FD9FB72DD69E7FDC401ACE8C9C9A492799CF19F18AFD455045D9FCC5AF02503FF31A08CAF65B4DEE92C21D8FEBF039C7A865BC34879A
        HEAD_REF master
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-uamqp-c
        REF 23DDABCC313FF0FC8B5DE68FC956B3EBD746CABF
        SHA512 614B36B960C20B045C91FD9FB72DD69E7FDC401ACE8C9C9A492799CF19F18AFD455045D9FCC5AF02503FF31A08CAF65B4DEE92C21D8FEBF039C7A865BC34879A
        HEAD_REF master
    )
endif()

file(COPY ${CURRENT_INSTALLED_DIR}/share/azure-c-shared-utility/azure_iot_build_rules.cmake DESTINATION ${SOURCE_PATH}/deps/azure-c-shared-utility/configs/)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Dskip_samples=ON
        -Duse_installed_dependencies=ON
        -Dbuild_as_dynamic=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/uamqp)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/azure-uamqp-c/copyright COPYONLY)

vcpkg_copy_pdbs()


