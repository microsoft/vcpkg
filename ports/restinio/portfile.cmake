include(vcpkg_common_functions)

set(RESTINIO_VERSION 0.4.7)

vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sobjectizerteam/restinio-0.4
    REF v.${RESTINIO_VERSION}
    SHA512 bc6eebfce9a2fb7faf9af7b14d7c96ec7b28be992681f65701145d5712ae2efe562b964ee7498944a9aa38a53281ed0928c3d6c000c842dbdb87deae1b5ebcad
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/vcpkg
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/restinio")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/restinio)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/restinio/LICENSE ${CURRENT_PACKAGES_DIR}/share/restinio/copyright)
