include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-iot-sdk-c
        REF 68d9964daa3e6754f6f8d98bbbd637b0967d4d29
        SHA512 5492AB06AE3686C7A167D63620D6CA00024DD52D46627D7958569F1EC0CFCA1B56151D54B8C7975F127F655018C10E830747EF84A0CDC66A44E903E25B2DC985
        HEAD_REF public-preview
        PATCHES improve-external-deps.patch
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-iot-sdk-c
        8c331e8552f754bb6e0502486ceee698625eb468
        CC6F34E04F237BB5E8E5445E033EEFAB00373D53A4847AB6089C9B8EB400AB87CED6905F1C78EA7D0DA3E9A56145E86A58D2F226FCF38F08659330A33D68F82E
        HEAD_REF master
        PATCHES improve-external-deps.patch
    )
endif()

file(COPY ${CURRENT_INSTALLED_DIR}/share/azure-c-shared-utility/azure_iot_build_rules.cmake DESTINATION ${SOURCE_PATH}/deps/azure-c-shared-utility/configs/)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Dskip_samples=ON
        -Duse_installed_dependencies=ON
        -Duse_default_uuid=ON
        -Dbuild_as_dynamic=OFF
        -Duse_edge_modules=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/azure_iot_sdks)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/azure-iot-sdk-c/copyright COPYONLY)

vcpkg_copy_pdbs()

