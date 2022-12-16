# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mandreyel/mio
    REF cafa31360fee8866be89b4c602d8b9a7a18dbf5e
    SHA512 21a5e6c6b90b9ac39bfe7fef59b6dc9c6dc3516b850de5897df63672e81e22abea7bdd7e363e8206dcb72697af797af2501b1c14480bbb8a9284f28c70ca9d67
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -Dmio.tests=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/mio)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/mio RENAME copyright)
