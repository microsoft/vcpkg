vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eclipse-ecal/fineftp-server
    REF "v${VERSION}"
    SHA512 ce658369d3250c99e9e05f927711d73285218c39c7e923c2a9a28d93d76cfb1d3746d30a186769847ba423ea6285c99f0af432fa919a07377b81b43e1733ccbc
    HEAD_REF master
    PATCHES
        asio.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME fineftp
    CONFIG_PATH lib/cmake/fineftp
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
