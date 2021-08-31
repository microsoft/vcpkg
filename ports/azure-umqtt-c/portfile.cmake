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
        REF 641d5aff878f398b3ab52f83e3757f798d4949f5
        SHA512 20c457c79fdf880a1ec627a33caa664a61c3ca8a0bf3b26ed3cecadcdbebcbca07f6d58c33996dda343bdd2c42c206fc1b9e46fe379ac5b79ba59a7dc23f2440
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
