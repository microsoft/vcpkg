vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO an-dr/microlog
    REF "v7.0.3"
    SHA512 6fab03d198917f39ba9a7bb44976d2367238e620adcd3864b4b541a08afdf2622b6654a2dbfd18422180fdd5811740b7c2d177d6a388a5e89ecac12e62452f71
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/microlog")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE "${CURRENT_PACKAGES_DIR}/LICENSE")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
