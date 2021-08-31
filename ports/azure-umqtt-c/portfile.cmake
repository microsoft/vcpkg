vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-umqtt-c
        REF 7557db6de094b67818d3c410dc95a3cf07cd86a6
        SHA512 f2577379f711e2576fdd6dfecbc4d8a0b26c7670a77bc468238e8dd5fa43f208db85eddd06dd570fde4219ba19304338c712f671c059c6cc10abb4892d58ae40
        HEAD_REF master
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-umqtt-c
        REF d066308a3fc5dd1a7219a97fcd96edf210477ac1
        SHA512 55f93d2df9d0a4d7a3225809c77f50010c21ce83ff2a8383ac2c239f2f968083fef57ae81898a6aa4077b9036378d0427dfc7e3aacc4aedb54723f303c61b33a
        HEAD_REF master
    )
endif()

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

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

vcpkg_copy_pdbs()
