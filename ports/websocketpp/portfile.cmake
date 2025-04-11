#header-only lib
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zaphoyd/websocketpp
    REF 56123c87598f8b1dd471be83ca841ceae07f95ba
    SHA512 f185a66e5a7c783254352a6ef87e2e559f681032b7368765d08393ed12bcae76825abed7dcaea73de09df644320409dad46279701f5f469520542a2c9b6a6163
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH cmake/)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

