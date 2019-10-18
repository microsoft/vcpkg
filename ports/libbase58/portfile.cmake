vcpkg_fail_port_install(MESSAGE "${PORT} currently only supports Linux platform" ON_TARGET "Windows" "OSX")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO luke-jr/libbase58
    REF v0.1.4
    SHA512 9b36fd7308a1a5486d77cb9baeeac49669a2c823998ff0885fee0757d6fca374f796b743e69af087e20a58b95556faf6c48106e034c09879937d96dae5fc7ac9
    HEAD_REF mater
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    NO_DEBUG
)

vcpkg_install_make()

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
