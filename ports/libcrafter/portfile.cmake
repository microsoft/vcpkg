#vcpkg_fail_port_install(MESSAGE "${PORT} currently only supports Linux platforms" ON_TARGET "Windows" "OSX")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pellegre/libcrafter
    REF version-0.3
    SHA512 7c396ba942b304dddfaa569adb44697f75568d3ef2ed48dda758e281f3b7c172439309033bbf5498069a4a61a952f93e41af99b129ce874ce76b5ec08da58116
    HEAD_REF master
    PATCHES fix-build-error.patch
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH libcrafter
    OPTIONS
        --with-libpcap=${CURRENT_INSTALLED_DIR}
)

vcpkg_install_make()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/libcrafter/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)