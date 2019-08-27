include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-macro-utils-c
    REF 17a6ad1df91e57d6981366710096798bcb5991a6
    SHA512 8f5b9561ff303832834113098a3c9eeace1f1fbbc55e508c50d0f75bfe08ee05b54a8d6a0786148c5e7861a0149317a2cc113022626f8ac72df732bda9162855
    HEAD_REF master
)

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


