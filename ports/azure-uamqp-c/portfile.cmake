include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-uamqp-c
        REF bd7b85d0830634e3157da2411a6d060bf28f266e
        SHA512 cbc2aa2765242ebe1a5e194e126f419cbd26edda5c1f72ffe9219a6c38b80aa91ef823a4fd8f78ac5d7ae0d9d471b50e5b8c4684e77c71b31e7cf35802e0cc17
        HEAD_REF public-preview
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-uamqp-c
        REF f29401ab5eb3853390d5f573d8fb37c0c96dba16
        SHA512 8fdee32e2a85218257ee91754873f9f8ae5e16cd2b7b10c88ab6d4115fe4378a2b08f211d8307346b0bd7688c4c896c25a4de34e9231c2506819a97bbf46dd73
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

# Fix relative paths that vcpkg_fixup_cmake_targets didn't pick up
set(TARGETS_CMAKE ${CURRENT_PACKAGES_DIR}/share/uamqp/uamqpTargets.cmake)
file(READ ${TARGETS_CMAKE} _contents)
string(REGEX REPLACE
    "get_filename_component\\(_IMPORT_PREFIX \"\\\${CMAKE_CURRENT_LIST_FILE}\" PATH\\)(\nget_filename_component\\(_IMPORT_PREFIX \"\\\${_IMPORT_PREFIX}\" PATH\\))*"
    "get_filename_component(_IMPORT_PREFIX \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)"
    _contents "${_contents}")
file(WRITE ${TARGETS_CMAKE} "${_contents}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/azure-uamqp-c/copyright COPYONLY)

vcpkg_copy_pdbs()
