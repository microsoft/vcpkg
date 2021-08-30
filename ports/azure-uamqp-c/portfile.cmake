vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-uamqp-c
        REF 065ffdeeb47313ddbbc2a8e84ad52ab033e2e8d2
        SHA512 bade6fae2d5479b7690632dbcc58bda5dd871eb0aa63d6a56cb35e81630121b5148309cd3414e6339c1218ec59fc12ac318b4964d295b579f7a0cacf5593b7ba
        HEAD_REF master
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-uamqp-c
        REF 98ba7f08403dec2261d03d5ced3a0d71023f525a
        SHA512 fbac11d12f45fb45e0ddf86251a8dc5f7bef3e0b7959bbc54001d84230b1ce6ef5eb317336d331000cb21943f4e9485e1186aa15a94f2dcf1f18a780fe6841ed
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

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

vcpkg_copy_pdbs()
