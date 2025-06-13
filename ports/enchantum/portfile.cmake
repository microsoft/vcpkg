vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ZXShady/enchantum
    REF 0.2.0
    SHA512 2c7ae9bea13fe1e599801c8df20036ea501216ce1554f06f18a172b8982d7d83352787c2d0c28cec5661afa7d61c1c8206cf7b92896640a10a952a5c3db54727
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
