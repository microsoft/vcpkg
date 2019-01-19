include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kmhofmann/selene
    REF v0.3
    SHA512 53a4a6577b4e618c5b080e0ddaa1e0e28b7c0a27e800eb9d1b1a2a6fbfaf630a6f326a3d070ad0c3f9bd8fb5e6bdd7fafbbd5a49e5f9a6f9ae79e0b50d20f741
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/selene")
vcpkg_copy_pdbs()

# Include files should not be duplicated into the /debug/include directory.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/selene RENAME copyright)
