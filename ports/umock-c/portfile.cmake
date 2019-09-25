include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/umock-c
    REF 1b2b14e9f45536894fe516b6dbb380b0507d779a
    SHA512 4933408296a1e1095be967a434bc9572411e38b78592606c40f51a2e651ee105f4761f888e8db36dd579539c4ebc07c9ae28cd1ff8ef0b720ce9b01a23e8861d
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


