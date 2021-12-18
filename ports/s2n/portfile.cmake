vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aws/s2n-tls
    REF 4513f8d707a68388990886d353e7cfe46cc6454b # v1.1.1
    SHA512 6586e330733982ed3b70fd320e63575639d5793d69ffa06b2a46ed487d55d8271b46df611d62cc48410654b394d599de65edd9cdc860dea13255161d843f1f48
    PATCHES fix-cmake-target-path.patch
            remove-libcrypto-messages.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/s2n/cmake)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/lib/s2n"
	"${CURRENT_PACKAGES_DIR}/lib/s2n"
	)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE	"${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
