vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-macro-utils-c
        REF 7523af934fc4d9423111e358f49b19314ec9c3e3
        SHA512 441d2420be319195ef50d0b03028e44c470adedc316dc338245cbc51ec2e78863cb42a9665d84a628056d212927abb5aeaf5c489e7c36b5257b16a28b3652e6e
        HEAD_REF master
        FILE_DISAMBIGUATOR 1
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-macro-utils-c
        REF 5926caf4e42e98e730e6d03395788205649a3ada
        SHA512 8f9fd02012202db6cff5b647edbc8332a2c03963e80182a630af6a884f23df96b8e24d60e5412bfc2a0a7f43240a54f9597040aa28a9d3e1566755e1d52aac62
        HEAD_REF master
        FILE_DISAMBIGUATOR 1
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
