include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/umock-c
    REF 92772d9d8317a37dd0b656e95877ffb03bc67e92
    SHA512 4dd738c7b2c7e1237ad874a7ad90bf81b864aa242af335dcc82d0cfea51bc33fe84de4eebedb6e00944c70d01d1ade4827716dbcf95754165b35981bde4147e7
    HEAD_REF master
)

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


