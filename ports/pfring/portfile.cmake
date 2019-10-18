vcpkg_fail_port_install(MESSAGE "${PORT} currently only supports Linux and Mac platforms" ON_TARGET "Windows")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ntop/PF_RING
    REF 15c8a3fd01c419b888f379c69c53c90380835200
    SHA512 162db2c5889318ab022a286933e5242907267da8566cc1a6479b67a0124e77a9810d8b59e4f6738a6c0ed1697ec836b85c73ab6a788b7ca5458f1a4d1b113fde
    HEAD_REF dev
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    SKIP_CONFIGURE
)

vcpkg_install_make()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

#Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)