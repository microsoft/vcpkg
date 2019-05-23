include(vcpkg_common_functions)

vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sobjectizerteam/restinio-0.4
    REF v.0.4.9
    SHA512 a839d3178d89e954bd47a40c7468e1ab2b34786c0122897620d9d8cff36e9d2c50b5e93d0774f7bdba8a17f91ea7dc2730135a6cdcb76aad5d8f5079ee1d9fdd
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
