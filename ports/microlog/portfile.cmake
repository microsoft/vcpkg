vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO an-dr/microlog
    REF "v7.0.2"
    SHA512 0a5714ed47724fde3784a8857a3ffcec41edcb22898ed178af0f37ccf86c3256275adb308d5ac393e01fcd10e7c0b3b597fc1dd91050d7ca5daebac6cf25983b
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
