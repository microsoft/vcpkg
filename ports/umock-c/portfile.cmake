include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/umock-c
        REF 87d2214384c886a1e2406ac0756a0b3786add8da
        SHA512 230b6c79a8346727bbc124d1aefaa14da8ecd82b2a56d68b3d2511b8efa5931872da440137a5d266835ba8c5193b83b4bc5ee85abb5242d07904a0706727926c
        HEAD_REF master
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/umock-c
        REF 5e3d93112360ee2d4a622b1c48eb70896da3e8c7
        SHA512 9f5c0ce782f66a41e702e2d54dcff92b07b30e7c2be0ee2c63a56e2bff0c26a1de7f77abcb2a964d668deea817dcb3a4771e328707c2d982c23526465c950608
        HEAD_REF master
    )
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Drun_unittests=OFF
        -Drun_int_tests=OFF
        -Duse_installed_dependencies=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/umock_c)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${SOURCE_PATH}/readme.md ${CURRENT_PACKAGES_DIR}/share/umock-c/copyright COPYONLY)

vcpkg_copy_pdbs()


