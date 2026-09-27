vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO unimails/unimail-cpp-sdk
    REF "v${VERSION}"
    SHA512 9aaadbfb348bc1b76708c66fbdc7a761431b7ad634a9b8390486fb997b35f694119363d653b486d87e65fca3ac2d4db035a81ce154e2a09b10385e37f4a42f0b
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUNIMAIL_TEST=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/unimail-cpp-sdk)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
