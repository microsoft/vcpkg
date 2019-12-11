include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-macro-utils-c
        REF 7523af934fc4d9423111e358f49b19314ec9c3e3
        SHA512 b53765096654fff9c5670004e4e107bffa81dd07e63eeac687c9e2b7e5ea2e1f26b6ae025c05c45f5c28152a457922f08c7f8d3303fa4d3b9194c34ba59533d5
        HEAD_REF master
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-macro-utils-c
        REF 7523af934fc4d9423111e358f49b19314ec9c3e3
        SHA512 b53765096654fff9c5670004e4e107bffa81dd07e63eeac687c9e2b7e5ea2e1f26b6ae025c05c45f5c28152a457922f08c7f8d3303fa4d3b9194c34ba59533d5
        HEAD_REF master
    )
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Drun_int_tests=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/azure_macro_utils_c)

file(COPY ${SOURCE_PATH}/inc/azure_macro_utils/macro_utils.h DESTINATION ${CURRENT_PACKAGES_DIR}/share/azure_macro_utils_c/include/azure_macro_utils)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/azure-macro-utils-c/copyright COPYONLY)

vcpkg_copy_pdbs()


